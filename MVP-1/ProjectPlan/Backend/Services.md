# Flat Wire Mill — Backend Services

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `03-HLD-and-ERDiagram.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Solution structure, CQRS, validation and error handling
**Status:** Baselined for build
**Owner:** Backend (.NET) stream
**Audience:** .NET developers
**Shortcode:** `[SVC]`
**Part of:** `ProjectPlan/Backend/` — index: [README.md](../README.md)

---

## 3. Backend design

### 3.1 Solution structure

```
API/Domain/FlatWire/
├── FlatWire.sln
├── FlatWire.API/            controllers (thin) + Hubs/FlatWireHub.cs + Program.cs + appsettings
├── FlatWire.Application/    Commands/ and Queries/ (MediatR), pipeline behaviors
├── FlatWire.Domain/         AggregatesModel/, ParamModels/, Enums/, IFlatWireClient
└── FlatWire.Infrastructure/ Repositories/, Services/PLCTagService.cs, Context/FlatWireDbContext.cs
```

Project references: `API → Application, Domain, Infrastructure` · `Application → Domain` · `Infrastructure → Domain`.

### 3.2 Layering rules

| Layer | Contains | Must not contain |
|---|---|---|
| **API** | Controllers extending `UAController`, `FlatWireHub`, DI wiring, `Program.cs` | Business logic, EF queries, direct OPC calls |
| **Application** | MediatR command/query handlers, FluentValidation validators, pipeline behaviours | EF `DbContext` types, HTTP types, SignalR types |
| **Domain** | Aggregates (`FlatWireRun`, `PassSchedule`, `RodStaging`, `WeldEvent`, `CoilOutput`), enums, `IFlatWireClient` | Persistence concerns, framework attributes |
| **Infrastructure** | `FlatWireDbContext`, repositories, Dapper readers, `PLCTagService`, the OPC hosted service | Business rules |

**Controllers are thin.** All logic routes through MediatR. Every controller and endpoint carries `[Authorize]`.

### 3.3 CQRS and data access

Data access is **mixed per UAL convention**:

| Access | Technology | Used for |
|---|---|---|
| Entity writes | **EF Core** via `FlatWireDbContext` | Every command — check-in, staging, weld, SPC, override, checkout, coil completion |
| High-volume reads | **Dapper** | Gauge trace, shift summary, list grids, the staging-queue projection |

Two read procedures back the heaviest queries (§6.8): `sp_GetGaugeTrace` and `sp_ShiftSummary`.

### 3.4 Validation, behaviours and errors

| Concern | Implementation |
|---|---|
| Request validation | **FluentValidation** per command, invoked by a MediatR pipeline behaviour. Examples: the mandatory FM2 stand `FM2_S3` must be `Active`; FL3 requires `RouteMode = Hybrid`; `State ∈ {Active, Bypass, Skip}`; `lineId = FL2` is rejected at `/staging/rod` |
| Response envelope | `UAController` standard `Data` / `Success` / `Errors` — see `[API §1]` |
| Logging | **Serilog**, structured, with the correlation ID from the inbound header |
| Error handling | Domain rule violation → `422`; concurrency / uniqueness → `409`; not found → `404`; PLC failure → `500` with the transaction aborted and compensating writes issued |
| Concurrency | `ROWVERSION` tokens on `PassSchedule`, `Rod`, `FlatWireRun`, `Spool`, `CoilOutput` |

---
