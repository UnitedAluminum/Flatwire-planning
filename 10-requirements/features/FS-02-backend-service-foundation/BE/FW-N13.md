---
id: FW-N13
legacy_id:
title: FlatWire/GetServerConnectionInfo — the shared header's environment badge
status: not-started
status_confirmed: true
status_note: "⬜ **Not started, and it is the smallest live defect in the module.** Every flat wire screen mounts `shared`'s `lib-header`, which calls `getServerConnectionInfo(url, suffix)` with the suffix `FlatWire/GetServerConnectionInfo` that `api-methods.constants.ts` **already declares** — and **no FlatWire controller implements it**, so the call 404s and the environment badge stays blank on every screen. ✅ **Four sibling services carry the identical action** — `CoilReceiving`, `FurnaceScheduler`, `Login` and `SlitterInterface` — so this is a copy, not a design. ⚠ **It fails silently by construction**: `lib-header` subscribes with no error branch, so nothing surfaces and nothing logs"
owner:
jira:
mvp: 1
phase: "1B"
stream: BE
streams: [BE]
priority: medium
hours: 3
sprint: S0
depends_on: [FW-138]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N13 - FlatWire/GetServerConnectionInfo — the shared header's environment badge

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

> ### ⚠ Why this exists — measured, not inferred
>
> `flat-wire.component` sets `serverName` to
> `{ url: getEndpoint().flatWireApiUrl, suffix: FLAT_WIRE_API_METHODS.GET_SERVER_INFO_FLAT_WIRE }`,
> exactly as `slitter-interface.component` and `coil-receiving.component` do. `lib-header` then calls
> `sharedApiService.getServerConnectionInfo(url, suffix)` and renders the environment label from the
> response.
>
> ⛔ **The client half is complete and the server half does not exist.**
> `api-methods.constants.ts` already declares
> `GET_SERVER_INFO_FLAT_WIRE: 'FlatWire/GetServerConnectionInfo'` — its only entry — while a search
> across `API/Domain/FlatWire` for `GetServerConnectionInfo` returns **nothing**. The same search
> across the other domains returns it in `CoilReceivingController`, `FurnaceSchedulerController`,
> `LoginController` and `SlitterInterfaceController`.
>
> ⚠ **The consequence is cosmetic but universal**: the header's environment badge is blank on every
> flat wire screen, and because `lib-header` subscribes without an error branch, **nothing surfaces
> and nothing logs**. It presents as "the badge does not work on this module".

## 1. What to build

**Hours:** 3 h BE · **Priority:** Medium · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As an** operator at a shopfloor terminal,
**I want** the header to tell me which environment and database server I am connected to,
**So that** I never record production work against a test instance, or the reverse.

**Acceptance Criteria:**
- [ ] A `GetServerConnectionInfo` action on a FlatWire controller, returning `ActionResult<ActionResultBase<string>>`, **copied from one of the four sibling implementations** rather than designed
- [ ] Reachable at `api/v1/flatwire/GetServerConnectionInfo`, which is what the client's `prefix` + `flatWireApiUrl` + the declared suffix already composes to — ⛔ **no client change is required or permitted**
- [ ] Returns the database server the service is actually connected to, so `[DEP §2]`'s `test1` instance `DEV00164-001` is distinguishable from production
- [ ] Verified in the browser: the header's environment label renders on `#/flat-wire` instead of staying blank

**Rate-card basis:** query endpoint **3 h** (`[CE §2]`) — a thin read with no MediatR handler, no validator and no new contract
**Dependencies:** FW-138 *(the thin controllers over `UAController`, done)*
**Blockers:** —

---
