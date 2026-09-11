/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 36_FlatWireDB_Synonyms_SharedReads.sql
  Objects      : FlatWireDB.dbo.coils   (SYNONYM -> CommonDB.dbo.coils)
                 *** dbo.Alloys is NOT created here - it ALREADY EXISTS on the target instance and
                     is deliberately left alone. See C6. ***
  Target DBs   : FlatWireDB (synonym home)
                 CommonDB   (dbo.coils  - READ ONLY, the one physical coil master)
                 united_db  (dbo.Alloys - READ ONLY, the alloy lookup)
  Last Updated : 2026-09-10
  Status       : Draft - no open sign-off items. It creates READS and writes nothing.
  Story        : FW-N35 (the rod existence read), P-351, P-353
  Specification: APIs.md Sec 4.22 - GET /checkin/rod/{alpha}
                 DatabaseDesign.md Sec 6.6 - the shared-read convention, CORRECTED 10 Sep 2026
                 Integration.md Sec 7.9 - the coils -> Rod column mapping
                 FR-064 / CHK006 (validate the rod alpha against coils), FR-530 (a read creates
                 nothing), D-32 (the shared schema is read as it stands and never altered)

  PURPOSE
  -------
  Surfaces the shared coil master inside FlatWireDB, so the Dashboard 2 check-in gate can answer
  "does this rod exist, and what is it?" without a three-part name at the call site. The alloy
  lookup it joins is already surfaced there by an object this repository does not own (C6).

  FR-064 requires the rod number to be validated against coils. P-54 withdrew GET /rod/{alpha}
  and assigned that data to "the receiving team's own surface", which exists in none of the four
  checkouts - so P-351 hosts the CHECK-IN GATE here instead. Rod RECEIVING remains another team's:
  no top-level rod surface, no ingestion, nothing written.

  *** DO NOT WRITE A SLASH-STAR SEQUENCE ANYWHERE IN THIS FILE'S COMMENTS. ***
  T-SQL block comments NEST. Writing the rod route with a wildcard - slash, r-o-d, slash, star -
  opens a nested comment, the next close mark ends only that one, and the header runs on to the
  end of the file: "Msg 113, Missing end comment mark". Measured here on 10 Sep 2026, twice.

  *** SYNONYMS, NOT VIEWS - AND Sec 6.6 SAID THE OPPOSITE UNTIL 10 Sep 2026. ***
  Measured in ual-database: Alloys is a SYNONYM in six databases (AccountingDB, CommonDB,
  InventoryDB, MillsDB, PackingDB, SlitterDB) and a VIEW in exactly one (PlanningDB); coils is a
  synonym in six, every one of them targeting CommonDB. P-353 corrects Sec 6.6 and states the rule:
  a SYNONYM when the read is a pass-through, a VIEW only when columns must be reshaped or renamed.
  35_ stays a view under that rule because it renames WIPStation -> Station.

  *** A SYNONYM IS A READ, SO D-32 HOLDS. No shared object is created, altered or dropped. ***

  SIX THINGS TO KNOW BEFORE EDITING THIS FILE
  -------------------------------------------
  C1. *** EACH SYNONYM TARGETS AN ACTUAL TABLE, NEVER ANOTHER SYNONYM. ***
      proddb.dbo.coils is ITSELF a synonym for CommonDB..coils - six databases carry the same one -
      and SQL Server does not permit a synonym on a synonym. The chain FAILS AT QUERY TIME, NOT AT
      CREATION, so pointing this at proddb..coils would deploy perfectly and break later, in
      somebody else's session, with an error naming this object. Prove the target before editing:

          SELECT type_desc FROM sys.objects WHERE object_id = OBJECT_ID(N'CommonDB.dbo.coils');
          -- USER_TABLE is the only acceptable answer. SYNONYM means you have the wrong name.

  C2. *** CREATE SYNONYM DOES NOT BIND AT CREATION - THE OPPOSITE HAZARD FROM 35_. ***
      A view binds its referenced objects at creation and fails outright (Msg 208) without its
      shared database. A synonym defers, so this script succeeds ANYWHERE - including on an
      instance with no CommonDB - and fails only when something queries it. Section 2 below is
      therefore a POST-CREATE verification block that reports rather than a pre-flight guard that
      aborts: the script stays green and says what will not work.

  C3. *** SELECT ONLY, AND ONLY TO ua_user. ***
      The six legacy synonym scripts in ual-database grant DELETE/INSERT/SELECT/UPDATE to [public].
      This one must not: write access would make FlatWireDB a write path into the shared schema,
      which D-32 forbids.

  C4. *** THE GRANT BELOW IS NOT WHAT MAKES THE READ WORK. ***
      A synonym carries NO permission across the database boundary. SQL Server checks rights on the
      BASE OBJECT, IN ITS OWN DATABASE, at execution time. A missing right in CommonDB surfaces as
      an error naming dbo.coils - i.e. pointing at THIS database - which sends people looking in the
      wrong place. 20_FlatWire_Grants.sql, which makes ua_user a real user with db_datareader in
      all six databases and says in terms that "ownership chaining is not relied on", is a
      PREREQUISITE of this file, not a companion to it. Verify with EXECUTE AS USER, never as the
      deploying login (Section 3).

  C5. *** A SYNONYM RESHAPES NOTHING, SO THE READING QUERY DOES. ***
      coils.coil_no is char(9) and SPACE-PADDED, so 'R00041' sits on disk as 'R00041   ' and an
      untrimmed predicate misses. The weights are smallint on coils and DECIMAL(8,2) in the
      contract. coil_alloy is the alloy DESIGNATION as a number, so it is resolved by joining
      Alloys on the NAME - alloys.alloy = CAST(coil_alloy AS VARCHAR(10)).
      *** NOT ON alloy_idx, WHICH MATCHES 0 OF 1,776 REAL ROWS - G133, corrected 10 Sep 2026. ***
      Either mistake fails SILENTLY: the idx join yields a blank alloy, and a bare cast yields the
      code as text. Both stop every downstream alloy comparison matching. All of that lives in ContextRepository's single
      Dapper query - the only reader - and is specified in [INT Sec 7.9].

  C6. *** FOUR SYNONYMS ALREADY EXIST IN FlatWireDB ON DEV00164-001, AND NO SCRIPT HERE CREATES
      THEM: accounts, alloys, Lookups, vendors. ***
      Measured 10 Sep 2026, on the first run of this file against the shared instance. dbo.alloys
      already targets [united_db]..[alloys] - the same object this file was written to create, since
      the collation is case-insensitive. That is DRIFT between the deployed database and source
      control, of the same kind G100 recorded for CommonDB's columns, and it is recorded rather than
      absorbed: this file creates coils ONLY, and touches nothing it did not author.
      ⚠ The alloy read therefore depends on an object THIS REPOSITORY DOES NOT TRACK. If it is ever
      dropped, the coil-master read fails on the join and not on the rod - Sec 2 reports its absence
      for exactly that reason.
      ⚠ 35_ (the WIPStations view) is likewise NOT deployed there - the database has zero views.

  DEPLOYMENT
  ----------
  *** DEPLOY TO THE SHARED INSTANCE, NOT LocalDB. *** FlatWireDB must sit alongside CommonDB and
  united_db or these synonyms resolve to nothing. DEV00164-001 is where co-location was proven.

      sqlcmd -S "DEV00164-001" -E -C -b -i 36_FlatWireDB_Synonyms_SharedReads.sql

  Re-runnable: the synonym is dropped if present and re-created, so the file is idempotent.
==============================================================================================*/

USE [FlatWireDB];
GO

/*----------------------------------------------------------------------------------------------
  Sec 1. The synonym.

  Same shape as the six legacy files at ual-database/Databases/<db>/Synonyms/ - DROP IF EXISTS, then
  CREATE - so this folder does not invent a second convention. The target is a BASE TABLE (C1).

  *** ONE SYNONYM, NOT TWO - AND THE MISSING ONE IS THE FINDING. ***
  This file created dbo.Alloys as well until it was first run against DEV00164-001 on 10 Sep 2026,
  which showed that FlatWireDB THERE ALREADY HAS FOUR SYNONYMS - accounts, alloys, Lookups and
  vendors - that NO SCRIPT IN THIS FOLDER CREATES. dbo.alloys already points at [united_db]..[alloys],
  which is the same object this file was about to create: the collation is case-insensitive, so
  dbo.Alloys and dbo.alloys are one name.

  So creating it here would DROP AND RECREATE an object this repository did not author and does not
  track, on a shared instance, to arrive at exactly where it already was. The alloy read works
  through the existing synonym; ⛔ leave it alone. See C6.
----------------------------------------------------------------------------------------------*/
DROP SYNONYM IF EXISTS [dbo].[coils];
GO

CREATE SYNONYM [dbo].[coils] FOR [CommonDB].[dbo].[coils];
GO

/*----------------------------------------------------------------------------------------------
  Sec 2. Post-create verification - REPORTS, does not abort (C2).

  A synonym is created without its target being checked, so "created successfully" says nothing
  about whether it will resolve. This block says what a query would find. It deliberately does NOT
  RAISERROR: a FlatWireDB-only instance is a legitimate place to run the schema, and the run stays
  green while naming exactly what is missing.

  OBJECT_ID is called WITHOUT a type argument on purpose. Passing N'U' would report a synonym-
  chained or renamed target as simply absent, which is the confusing failure C1 warns about.
----------------------------------------------------------------------------------------------*/
IF DB_ID(N'CommonDB') IS NULL
    PRINT 'WARNING: CommonDB is not on this instance. dbo.coils is created but will NOT resolve.';
ELSE IF OBJECT_ID(N'[CommonDB].[dbo].[coils]') IS NULL
    PRINT 'WARNING: CommonDB is present but dbo.coils is not visible to this login. Run 20_FlatWire_Grants.sql first (C4).';
ELSE
    PRINT 'OK: dbo.coils -> CommonDB.dbo.coils resolves.';

/*
 * The alloy synonym is NOT created here (Sec 1), but the read depends on it, so this reports
 * whether it is present rather than assuming the instance still carries it.
 */
IF OBJECT_ID(N'[dbo].[Alloys]', N'SN') IS NULL
    PRINT 'WARNING: dbo.Alloys does not exist in this database. The coil-master read resolves the alloy NAME through it, and without it that read fails - see C6.';
ELSE IF DB_ID(N'united_db') IS NULL
    PRINT 'WARNING: dbo.Alloys exists but united_db is not on this instance, so it will NOT resolve.';
ELSE
    PRINT 'OK: dbo.Alloys already exists and is left as it stands (C6).';
GO

/*----------------------------------------------------------------------------------------------
  Sec 3. Grants - SELECT only, to ua_user (C3), and see C4 for why this is the local half only.
----------------------------------------------------------------------------------------------*/
IF DATABASE_PRINCIPAL_ID(N'ua_user') IS NOT NULL
BEGIN
    IF OBJECT_ID(N'[dbo].[coils]', N'SN') IS NOT NULL
    BEGIN
        GRANT SELECT ON [dbo].[coils] TO [ua_user];
        PRINT 'Created synonym: FlatWireDB.dbo.coils -> CommonDB.dbo.coils (SELECT granted to ua_user)';
    END

    /*
     * ⛔ NO GRANT ON dbo.Alloys. This file does not create it (Sec 1, C6), so it does not grant on
     * it either - re-granting on somebody else's object would make this script an owner of it.
     */
END
ELSE
    PRINT 'NOTE: ua_user is not a principal in FlatWireDB - run 20_FlatWire_Grants.sql (C4).';
GO

/*----------------------------------------------------------------------------------------------
  Sec 4. Proving it, after deployment.

  The two reads below run as the DEPLOYING login and prove nothing about the service account -
  which is the failure this design is most likely to hit (C4). The third one is the real test.

      SELECT name, base_object_name FROM FlatWireDB.sys.synonyms;
      SELECT type_desc FROM CommonDB.sys.objects WHERE object_id = OBJECT_ID(N'CommonDB.dbo.coils');

      EXECUTE AS USER = 'ua_user';
      SELECT TOP 1 coil_no FROM dbo.coils;
      SELECT TOP 1 alloy   FROM dbo.Alloys;
      REVERT;

  Expected: base_object_name is [CommonDB].[dbo].[coils] - NOT proddb - and type_desc is USER_TABLE.
----------------------------------------------------------------------------------------------*/
