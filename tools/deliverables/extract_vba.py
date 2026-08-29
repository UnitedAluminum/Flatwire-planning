"""Extract VBA module source from a macro-enabled Office file (.xlsm / .docm).

Written 21 Aug 2026 to recover `Module1` from `BaseDocuments/FL Alphas Plus.xlsm`, whose
alpha-generation logic is analysed in `BaseDocuments/FL Alphas Plus - Analysis.md`.
Re-run it if that workbook is ever updated.

    python extract_vba.py "../../../BaseDocuments/FL Alphas Plus.xlsm" <output-dir>

Standard library only -- no oletools, no olefile, nothing to install.

WHY THIS EXISTS RATHER THAN A ONE-LINER
---------------------------------------
The VBA lives in `xl/vbaProject.bin`, an OLE (CFB) container whose module streams are
MS-OVBA RLE-compressed. Two traps make a naive read fail *silently*:

  1. A module stream begins with a large "performance cache", not with the source. In
     the FL Alphas workbook the cache is ~22 KB and the text starts at offset 22177.
  2. Scanning for the compressed-container signature byte 0x01 finds a FALSE start
     early in the cache (offset 61 in that file). It decompresses without error and
     the first few hundred bytes even look like valid source -- then degrade.

So the offset must come from the `dir` stream's MODULEOFFSET record (id 0x0031), which
is itself MS-OVBA-compressed. That is what this script does.

Read-only: it never writes to the input file.
"""
import io
import re
import struct
import sys
import zipfile

ENDOFCHAIN, FREESECT = 0xFFFFFFFE, 0xFFFFFFFF


class CFB:
    """Minimal Compound File Binary reader -- enough to list and read streams."""

    def __init__(self, data):
        if data[:8] != b'\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1':
            raise ValueError('not a CFB container')
        self.d = data
        self.ssz = 1 << struct.unpack_from('<H', data, 0x1e)[0]
        self.mssz = 1 << struct.unpack_from('<H', data, 0x20)[0]
        self.n_fat = struct.unpack_from('<I', data, 0x2c)[0]
        self.dir0 = struct.unpack_from('<I', data, 0x30)[0]
        self.cutoff = struct.unpack_from('<I', data, 0x38)[0]
        self.minifat0 = struct.unpack_from('<I', data, 0x3c)[0]
        self.n_minifat = struct.unpack_from('<I', data, 0x40)[0]
        self.difat0 = struct.unpack_from('<I', data, 0x44)[0]
        self.n_difat = struct.unpack_from('<I', data, 0x48)[0]
        self._read_fat()
        self._read_dir()
        self._read_minifat()

    def _sector(self, n):
        off = 512 + n * self.ssz
        return self.d[off:off + self.ssz]

    def _read_fat(self):
        difat = list(struct.unpack_from('<109I', self.d, 0x4c))
        nxt = self.difat0
        while self.n_difat and nxt not in (ENDOFCHAIN, FREESECT):
            vals = list(struct.unpack_from('<%dI' % (self.ssz // 4), self._sector(nxt), 0))
            difat.extend(vals[:-1])
            nxt = vals[-1]
        self.fat = []
        for sec in difat[:self.n_fat]:
            if sec in (FREESECT, ENDOFCHAIN):
                continue
            self.fat.extend(struct.unpack_from('<%dI' % (self.ssz // 4), self._sector(sec), 0))

    def _chain(self, start):
        out, s, guard = [], start, 0
        while s not in (ENDOFCHAIN, FREESECT) and guard < (1 << 20):
            out.append(s)
            s = self.fat[s]
            guard += 1
        return out

    def _read_dir(self):
        raw = b''.join(self._sector(s) for s in self._chain(self.dir0))
        self.entries = []
        for i in range(0, len(raw) - 127, 128):
            e = raw[i:i + 128]
            nlen = struct.unpack_from('<H', e, 0x40)[0]
            self.entries.append({
                'name': e[:max(0, nlen - 2)].decode('utf-16-le', 'replace'),
                'type': e[0x42],
                'start': struct.unpack_from('<I', e, 0x74)[0],
                'size': struct.unpack_from('<Q', e, 0x78)[0],
            })

    def _read_minifat(self):
        self.minifat = []
        if self.n_minifat:
            for s in self._chain(self.minifat0):
                self.minifat.extend(struct.unpack_from('<%dI' % (self.ssz // 4), self._sector(s), 0))
        root = next((e for e in self.entries if e['type'] == 5), None)
        self.mini = b''.join(self._sector(s) for s in self._chain(root['start'])) \
            if root and root['size'] else b''

    def read(self, entry):
        if entry['size'] >= self.cutoff or not self.mini:
            data = b''.join(self._sector(s) for s in self._chain(entry['start']))
        else:
            data, s, guard = b'', entry['start'], 0
            while s not in (ENDOFCHAIN, FREESECT) and guard < (1 << 20):
                data += self.mini[s * self.mssz:(s + 1) * self.mssz]
                s = self.minifat[s]
                guard += 1
        return data[:entry['size']]


def decompress(buf, start=0):
    """MS-OVBA CompressedContainer -> plain bytes. `start` must be the 0x01 signature."""
    if buf[start] != 0x01:
        raise ValueError('no 0x01 container signature at offset %d' % start)
    pos, out = start + 1, bytearray()
    while pos + 1 < len(buf):
        header = struct.unpack_from('<H', buf, pos)[0]
        size = (header & 0x0FFF) + 3          # includes the 2-byte header
        compressed = (header >> 15) & 1
        pos += 2
        end = min(pos + size - 2, len(buf))
        if not compressed:
            out.extend(buf[pos:pos + 4096])
            pos = end
            continue
        chunk_start, p = len(out), pos
        while p < end:
            flags = buf[p]
            p += 1
            for bit in range(8):
                if p >= end:
                    break
                if not (flags >> bit) & 1:
                    out.append(buf[p])
                    p += 1
                    continue
                token = struct.unpack_from('<H', buf, p)[0]
                p += 2
                diff = len(out) - chunk_start
                bits = 4
                while (1 << bits) < diff:
                    bits += 1
                bits = max(4, min(12, bits))
                length = (token & (0xFFFF >> bits)) + 3
                offset = (token >> (16 - bits)) + 1
                src = len(out) - offset
                if src < 0:
                    raise ValueError('copy token points before the chunk')
                for k in range(length):
                    out.append(out[src + k])
        pos = end
    return bytes(out)


def module_offsets(dir_stream):
    """(module name, text offset) pairs from the decompressed `dir` stream.

    Records are id(2) + size(4) + body, but the stream mixes fixed and variable
    layouts, so scan for the MODULEOFFSET signature (id 0x0031, size 4) and take the
    nearest preceding ASCII run as the module name. Robust enough, and the alternative
    is a full MS-OVBA record parser for two fields.
    """
    out = []
    for m in re.finditer(rb'\x31\x00\x04\x00\x00\x00', dir_stream):
        offset = struct.unpack_from('<I', dir_stream, m.end())[0]
        names = re.findall(rb'[A-Za-z_][A-Za-z0-9_]{2,}',
                           dir_stream[max(0, m.start() - 120):m.start()])
        name = names[-1].decode('latin-1') if names else '?'
        # the dir stream suffixes the name with a marker byte; strip a trailing digit/G
        name = re.sub(r'[G0-9]$', '', name)
        out.append((name, offset))
    return out


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    src, outdir = sys.argv[1], sys.argv[2]
    with zipfile.ZipFile(src) as z:
        vba = next((n for n in z.namelist() if n.endswith('vbaProject.bin')), None)
        if not vba:
            sys.exit('no vbaProject.bin in %s' % src)
        cfb = CFB(z.read(vba))

    entries = {e['name']: e for e in cfb.entries}
    if 'dir' not in entries:
        sys.exit('no `dir` stream -- cannot locate module text offsets')

    for name, offset in module_offsets(decompress(cfb.read(entries['dir']), 0)):
        entry = entries.get(name)
        if not entry:
            print('  %-16s SKIP (no matching stream)' % name)
            continue
        try:
            text = decompress(cfb.read(entry), offset).decode('latin-1')
        except Exception as exc:                      # noqa: BLE001 - report and continue
            print('  %-16s FAILED at offset %d: %s' % (name, offset, exc))
            continue
        path = '%s/%s.bas' % (outdir.rstrip('/'), name)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
        print('  %-16s offset=%-6d %6d bytes  %4d lines  -> %s'
              % (name, offset, len(text), len(text.splitlines()), path))


if __name__ == '__main__':
    main()
