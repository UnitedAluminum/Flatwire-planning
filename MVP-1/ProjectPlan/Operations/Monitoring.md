# Flat Wire Mill — Monitoring and Logging

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `07-DeploymentRunbookAndRollback.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Health monitoring and logging
**Status:** Baselined
**Owner:** Release manager / IT
**Audience:** IT / DevOps, on-call
**Shortcode:** `[MON]`
**Part of:** `ProjectPlan/Operations/` — index: [README.md](../README.md)

---

## 7. Operational readiness

---

### 7.1 Monitoring and health

| What | Where | Alert on |
|---|---|---|
| `GET /health` | `FlatWire.API` | Not-healthy, or `opc.reachable` false, for more than 2 minutes |
| App-pool state | IIS | Stopped, or recycling more than twice in an hour |
| Hub connection count | `FlatWireHub` | Drops to zero while any line is `Running` |
| **Broadcast cadence** | Hub instrumentation | Sustained deviation from the configured interval |
| `RunReading` growth rate | SQL Server | Rate change beyond the expected band — **and note there is no retention policy yet (OI-17)** |
| Failed PLC tag writes | Audit log | **Any** failure — each one aborted a check-in |
| Deadlocks / long-running queries | SQL Server | Standard UAL thresholds |

---

### 7.2 Logging

| Item | Value |
|---|---|
| Framework | **Serilog**, structured, per the UAL convention |
| Location | `logs/app-<date>.txt` under the API site |
| Rolling | Daily, retaining 100 files |
| Enrichment | **Correlation ID on every line**, set by the shared `correlation-id-interceptor` |
| What is always logged | Every PLC tag write and clear (path, value, operator, timestamp, result) · every supervisor override · every pass-schedule change · every login/logout |
| What is **never** logged | **The supervisor PIN.** It authenticates only and is never stored, echoed or logged |
