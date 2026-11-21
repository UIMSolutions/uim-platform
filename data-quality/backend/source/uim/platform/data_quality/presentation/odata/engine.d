/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the CLI and the GUI.
module uim.platform.data_quality.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates DataQualityException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

/// Counters of every dataset of a tenant in one pass over records,
/// violations and match groups.
DatasetCounts[string] datasetCounts(DqPorts ports, TenantId t) {
  DatasetCounts[string] counts;
  auto all = DatasetId.init;
  foreach (r; ports.records.listRecords(t, all)) {
    auto c = &counts.require(r.datasetId.value, DatasetCounts.init);
    c.records++;
    if (r.violationCount > 0)
      c.invalidRecords++;
  }
  foreach (v; ports.validation.listViolations(t, all))
    counts.require(v.datasetId.value, DatasetCounts.init).violations++;
  foreach (g; ports.duplicates.listMatchGroups(t, all))
    if (!g.resolved)
      counts.require(g.datasetId.value, DatasetCounts.init).openDuplicates += g.duplicates.length;
  return counts;
}

ODataEngine dataQualityEngine(DqPorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(dataQualityModel());
  auto all = DatasetId.init;

  // ── Datasets ────────────────────────────────────────────────────────────
  auto datasets = new DelegateEntitySetProvider;
  datasets.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto counts = datasetCounts(ports, t);
    return ports.datasets.listDatasets(t).map!(d => datasetRow(d, counts.get(d.id.value, DatasetCounts.init))).array;
  };
  datasets.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto d = ports.datasets.getDataset(t, DatasetId(key));
    return datasetRow(d, datasetCounts(ports, t).get(key, DatasetCounts.init));
  };
  datasets.onCreate = (const RequestContext ctx, Json p) => datasetRow(ports.datasets.createDataset(createDatasetRequest(ctx, p)));
  datasets.onUpdate = (const RequestContext ctx, string key, Json p) {
    auto t = tenantOf(ctx);
    auto d = ports.datasets.updateDataset(updateDatasetRequest(ctx, key, p));
    return datasetRow(d, datasetCounts(ports, t).get(key, DatasetCounts.init));
  };
  datasets.onRemove = (const RequestContext ctx, string key) {
    ports.datasets.deleteDataset(tenantOf(ctx), DatasetId(key), actorOf(ctx));
  };

  // ── Records ─────────────────────────────────────────────────────────────
  auto records = new DelegateEntitySetProvider;
  records.keyProperty = "key";
  records.onList = (const RequestContext ctx) => ports.records.listRecords(tenantOf(ctx), all).map!(r => recordRow(r)).array;
  records.onGet = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Record");
    return recordRow(ports.records.getRecord(tenantOf(ctx), ds, RecordId(id)));
  };
  records.onCreate = (const RequestContext ctx, Json p) => recordRow(ports.records.createRecord(createRecordRequest(ctx, p)));
  records.onUpdate = (const RequestContext ctx, string key, Json p) => recordRow(
    ports.records.updateRecord(updateRecordRequest(ctx, key, p)));
  records.onRemove = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Record");
    ports.records.deleteRecord(tenantOf(ctx), ds, RecordId(id), actorOf(ctx));
  };

  // ── Validation rules ────────────────────────────────────────────────────
  auto validationRules = new DelegateEntitySetProvider;
  validationRules.onList = (const RequestContext ctx) => ports.validationRules.listValidationRules(tenantOf(ctx))
    .map!(r => validationRuleRow(r)).array;
  validationRules.onGet = (const RequestContext ctx, string key) => validationRuleRow(
    ports.validationRules.getValidationRule(tenantOf(ctx), ValidationRuleId(key)));
  validationRules.onCreate = (const RequestContext ctx, Json p) => validationRuleRow(
    ports.validationRules.createValidationRule(createValidationRuleRequest(ctx, p)));
  validationRules.onUpdate = (const RequestContext ctx, string key, Json p) => validationRuleRow(
    ports.validationRules.updateValidationRule(updateValidationRuleRequest(ctx, key, p)));
  validationRules.onRemove = (const RequestContext ctx, string key) {
    ports.validationRules.deleteValidationRule(tenantOf(ctx), ValidationRuleId(key));
  };

  // ── Violations (read only) ──────────────────────────────────────────────
  auto violations = new DelegateEntitySetProvider;
  violations.keyProperty = "key";
  violations.onList = (const RequestContext ctx) => ports.validation.listViolations(tenantOf(ctx), all)
    .map!(v => violationRow(v)).array;
  violations.onGet = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Violation");
    return violationRow(ports.validation.getViolation(tenantOf(ctx), ds, ViolationId(id)));
  };

  // ── Cleansing rules ─────────────────────────────────────────────────────
  auto cleansingRules = new DelegateEntitySetProvider;
  cleansingRules.onList = (const RequestContext ctx) => ports.cleansingRules.listCleansingRules(tenantOf(ctx))
    .map!(r => cleansingRuleRow(r)).array;
  cleansingRules.onGet = (const RequestContext ctx, string key) => cleansingRuleRow(
    ports.cleansingRules.getCleansingRule(tenantOf(ctx), CleansingRuleId(key)));
  cleansingRules.onCreate = (const RequestContext ctx, Json p) => cleansingRuleRow(
    ports.cleansingRules.createCleansingRule(createCleansingRuleRequest(ctx, p)));
  cleansingRules.onUpdate = (const RequestContext ctx, string key, Json p) => cleansingRuleRow(
    ports.cleansingRules.updateCleansingRule(updateCleansingRuleRequest(ctx, key, p)));
  cleansingRules.onRemove = (const RequestContext ctx, string key) {
    ports.cleansingRules.deleteCleansingRule(tenantOf(ctx), CleansingRuleId(key));
  };

  // ── Cleansing jobs ──────────────────────────────────────────────────────
  auto jobs = new DelegateEntitySetProvider;
  jobs.keyProperty = "key";
  jobs.onList = (const RequestContext ctx) => ports.cleansingJobs.listCleansingJobs(tenantOf(ctx), all)
    .map!(j => cleansingJobRow(j)).array;
  jobs.onGet = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Cleansing job");
    return cleansingJobRow(ports.cleansingJobs.getCleansingJob(tenantOf(ctx), ds, CleansingJobId(id)));
  };
  jobs.onCreate = (const RequestContext ctx, Json p) => cleansingJobRow(
    ports.cleansingJobs.createCleansingJob(createCleansingJobRequest(ctx, p)));
  jobs.onRemove = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Cleansing job");
    ports.cleansingJobs.deleteCleansingJob(tenantOf(ctx), ds, CleansingJobId(id));
  };

  // ── Match groups ────────────────────────────────────────────────────────
  auto groups = new DelegateEntitySetProvider;
  groups.keyProperty = "key";
  groups.onList = (const RequestContext ctx) => ports.duplicates.listMatchGroups(tenantOf(ctx), all)
    .map!(g => matchGroupRow(g)).array;
  groups.onGet = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Match group");
    return matchGroupRow(ports.duplicates.getMatchGroup(tenantOf(ctx), ds, MatchGroupId(id)));
  };
  groups.onRemove = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Match group");
    ports.duplicates.deleteMatchGroup(tenantOf(ctx), ds, MatchGroupId(id));
  };

  // ── Column profiles (read only) ─────────────────────────────────────────
  auto columns = new DelegateEntitySetProvider;
  columns.keyProperty = "key";
  columns.onList = (const RequestContext ctx) => ports.profiling.listColumnProfiles(tenantOf(ctx), all)
    .map!(c => columnProfileRow(c)).array;
  columns.onGet = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Column profile");
    return columnProfileRow(ports.profiling.getColumnProfile(tenantOf(ctx), ds, ColumnProfileId(id)));
  };

  // ── Addresses ───────────────────────────────────────────────────────────
  auto addresses = new DelegateEntitySetProvider;
  addresses.onList = (const RequestContext ctx) => ports.addresses.listAddresses(tenantOf(ctx)).map!(a => addressRow(a)).array;
  addresses.onGet = (const RequestContext ctx, string key) => addressRow(ports.addresses.getAddress(tenantOf(ctx), AddressId(key)));
  addresses.onCreate = (const RequestContext ctx, Json p) => addressRow(ports.addresses.cleanseAddress(cleanseAddressRequest(ctx, p)));
  addresses.onRemove = (const RequestContext ctx, string key) {
    ports.addresses.deleteAddress(tenantOf(ctx), AddressId(key));
  };

  // ── Quality snapshots ───────────────────────────────────────────────────
  auto snapshots = new DelegateEntitySetProvider;
  snapshots.keyProperty = "key";
  snapshots.onList = (const RequestContext ctx) => ports.scorecards.listSnapshots(tenantOf(ctx), all)
    .map!(s => snapshotRow(s)).array;
  snapshots.onGet = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Snapshot");
    return snapshotRow(ports.scorecards.getSnapshot(tenantOf(ctx), ds, SnapshotId(id)));
  };
  snapshots.onRemove = (const RequestContext ctx, string key) {
    DatasetId ds;
    string id;
    splitKey(key, ds, id, "Snapshot");
    ports.scorecards.deleteSnapshot(tenantOf(ctx), ds, SnapshotId(id));
  };

  // ── Statistics (singleton) ──────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("Datasets", new PortProvider(datasets))
    .provide("Records", new PortProvider(records))
    .provide("ValidationRules", new PortProvider(validationRules))
    .provide("Violations", new PortProvider(violations))
    .provide("CleansingRules", new PortProvider(cleansingRules))
    .provide("CleansingJobs", new PortProvider(jobs))
    .provide("MatchGroups", new PortProvider(groups))
    .provide("ColumnProfiles", new PortProvider(columns))
    .provide("Addresses", new PortProvider(addresses))
    .provide("QualitySnapshots", new PortProvider(snapshots))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ─────────────────────────────────────────────────────────────
  DatasetId datasetParam(Json p) {
    auto id = textOf(p, "datasetId").strip;
    if (id.length == 0)
      throw DataQualityException.invalid("Parameter 'datasetId' is required");
    return DatasetId(id);
  }

  engine.handle("ValidateDataset", (const RequestContext ctx, Json p) => translated!Json(() => validationRunRow(
      ports.validation.validateDataset(tenantOf(ctx), datasetParam(p), actorOf(ctx)))));
  engine.handle("ValidateRecord", (const RequestContext ctx, Json p) => translated!Json(() {
      DatasetId ds;
      string id;
      splitKey(textOf(p, "key"), ds, id, "Record");
      return recordValidationRow(ports.validation.validateRecord(tenantOf(ctx), ds, RecordId(id), actorOf(ctx)));
    }));
  engine.handle("ProfileDataset", (const RequestContext ctx, Json p) => translated!Json(() => profileRunRow(
      ports.profiling.profileDataset(tenantOf(ctx), datasetParam(p), actorOf(ctx)))));
  engine.handle("DetectDuplicates", (const RequestContext ctx, Json p) => translated!Json(() => detectRow(
      ports.duplicates.detectDuplicates(detectRequest(ctx, p)))));
  engine.handle("ResolveMatchGroup", (const RequestContext ctx, Json p) => translated!Json(() {
      ResolveMatchGroupRequest r;
      r.tenantId = tenantOf(ctx);
      r.actor = actorOf(ctx);
      splitKey(textOf(p, "key"), r.datasetId, r.id, "Match group");
      r.survivorRecordId = textOf(p, "survivorRecordId");
      r.merge = boolOf(p, "merge");
      return resolveRow(ports.duplicates.resolveMatchGroup(r));
    }));
  engine.handle("ComputeScorecard", (const RequestContext ctx, Json p) => translated!Json(() => scorecardRow(
      ports.scorecards.computeScorecard(tenantOf(ctx), datasetParam(p), actorOf(ctx)))));
  engine.handle("TakeSnapshot", (const RequestContext ctx, Json p) => translated!Json(() {
      auto t = tenantOf(ctx);
      auto ds = datasetParam(p);
      ports.scorecards.takeSnapshot(t, ds, actorOf(ctx));
      return scorecardRow(ports.scorecards.computeScorecard(t, ds, actorOf(ctx)));
    }));
  engine.handle("RunCleansingJob", (const RequestContext ctx, Json p) => translated!Json(() {
      DatasetId ds;
      string id;
      splitKey(textOf(p, "key"), ds, id, "Cleansing job");
      return jobResultRow(ports.cleansingJobs.runCleansingJob(tenantOf(ctx), ds, CleansingJobId(id), actorOf(ctx)));
    }));
  engine.handle("CancelCleansingJob", (const RequestContext ctx, Json p) => translated!Json(() {
      DatasetId ds;
      string id;
      splitKey(textOf(p, "key"), ds, id, "Cleansing job");
      return jobResultRow(ports.cleansingJobs.cancelCleansingJob(tenantOf(ctx), ds, CleansingJobId(id), actorOf(ctx)));
    }));
  engine.handle("ImportCsv", (const RequestContext ctx, Json p) => translated!Json(() {
      ImportRecordsRequest r;
      r.tenantId = tenantOf(ctx);
      r.actor = actorOf(ctx);
      r.datasetId = datasetParam(p);
      r.records = parseCsvRecords(textOf(p, "csv"));
      r.createDataset = boolOf(p, "createDataset");
      r.replaceExisting = boolOf(p, "replaceExisting", true);
      return importRow(ports.records.importRecords(r));
    }));
  engine.handle("SeedDemoData", (const RequestContext ctx, Json p) => translated!Json(() => seedRow(
      seedDemoData(ports, tenantOf(ctx), actorOf(ctx)))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
