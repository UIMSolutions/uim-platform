/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.records;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ManageRecordsUseCase : DqInteractor, IManageRecords {
  protected ValidateDataUseCase validation;
  protected ManageScorecardsUseCase scorecards;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy,
    ValidateDataUseCase validation, ManageScorecardsUseCase scorecards) {
    super(repos, clock, events, unitOfWork, policy);
    this.validation = validation;
    this.scorecards = scorecards;
  }

  DataRecord createRecord(CreateRecordRequest r) {
    datasetOf(r.tenantId, r.datasetId);
    auto id = idOrNew(r.id, "Record ID");
    if (repos.records.existsById(r.tenantId, r.datasetId, RecordId(id)))
      throw DataQualityException.conflict("Record '" ~ id ~ "' already exists in dataset '" ~ r.datasetId.value ~ "'");
    DataRecord record;
    stampCreated!(DataRecord, RecordId)(record, r.tenantId, r.actor, id, now);
    record.datasetId = r.datasetId;
    record.fields = checkedFields(r.fields);
    record.validate();
    repos.records.save(record);
    emit("record.created", r.tenantId, resourceKey(r.datasetId.value, id));
    return policy.autoValidate ? validation.validateRecord(r.tenantId, r.datasetId, record.id, r.actor) : record;
  }

  DataRecord updateRecord(UpdateRecordRequest r) {
    auto record = getRecord(r.tenantId, r.datasetId, RecordId(r.id));
    auto fields = checkedFields(r.fields);
    if (r.merge) {
      foreach (f; fields)
        record.fields = withField(record.fields, f.name, f.value);
    } else
      record.fields = fields;
    record.resetValidation();
    record.validate();
    stampUpdated(record, r.actor, now);
    repos.records.save(record);
    return policy.autoValidate ? validation.validateRecord(r.tenantId, r.datasetId, record.id, r.actor) : record;
  }

  DataRecord getRecord(TenantId t, DatasetId ds, RecordId id) {
    return recordOf(t, ds, id);
  }

  DataRecord[] listRecords(TenantId t, DatasetId ds) {
    return repos.records.findByDataset(t, ds);
  }

  void deleteRecord(TenantId t, DatasetId ds, RecordId id, UserId actor) {
    recordOf(t, ds, id);
    batch(() {
      repos.violations.removeByRecord(t, ds, id);
      repos.records.removeById(t, ds, id);
      // keep the open match groups consistent
      foreach (g; repos.matchGroups.findByDataset(t, ds)) {
        if (g.resolved || !g.contains(id))
          continue;
        g.candidates = g.candidates.filter!(c => c.recordId != id).array;
        if (g.candidates.length < 2)
          repos.matchGroups.removeById(t, ds, g.id);
        else
          repos.matchGroups.save(g);
      }
    });
    emit("record.deleted", t, resourceKey(ds.value, id.value));
    auto dataset = repos.datasets.findById(t, ds);
    if (!dataset.isNull && dataset.isScored)
      scorecards.computeScorecard(t, ds, actor);
  }

  ImportResult importRecords(ImportRecordsRequest r) {
    ImportResult result;
    result.datasetId = r.datasetId.value;
    if (r.records.length > policy.maxImportRecords)
      throw DataQualityException.invalid(format("At most %d records per import", policy.maxImportRecords));
    auto existing = repos.datasets.findById(r.tenantId, r.datasetId);
    if (existing.isNull) {
      if (!r.createDataset)
        throw DataQualityException.notFound("Dataset '" ~ r.datasetId.value ~ "'");
      requireId(r.datasetId.value, "Dataset ID");
    }

    // validate everything before writing anything
    DataRecord[] prepared;
    bool[string] seen;
    auto at = now;
    foreach (input; r.records) {
      auto id = idOrNew(input.id, "Record ID");
      if (id in seen)
        throw DataQualityException.invalid("Record '" ~ id ~ "' occurs twice in the import");
      seen[id] = true;
      DataRecord record;
      stampCreated!(DataRecord, RecordId)(record, r.tenantId, r.actor, id, at);
      record.datasetId = r.datasetId;
      record.fields = checkedFields(input.fields);
      record.validate();
      prepared ~= record;
    }

    batch(() {
      if (existing.isNull) {
        Dataset d;
        stampCreated!(Dataset, DatasetId)(d, r.tenantId, r.actor, r.datasetId.value, at);
        d.name = r.datasetId.value;
        d.validate();
        repos.datasets.save(d);
        result.datasetCreated = true;
      }
      foreach (record; prepared) {
        auto old = repos.records.findById(r.tenantId, r.datasetId, record.id);
        if (!old.isNull) {
          if (!r.replaceExisting) {
            result.skipped++;
            continue;
          }
          record.createdAt = old.createdAt;
          record.createdBy = old.createdBy;
          result.updated++;
        } else
          result.created++;
        repos.records.save(record);
      }
    });
    emit("records.imported", r.tenantId, r.datasetId.value, Json([
        "created": Json(result.created), "updated": Json(result.updated), "skipped": Json(result.skipped)
      ]));
    if (r.validate && (result.created + result.updated) > 0) {
      result.validation = validation.validateDataset(r.tenantId, r.datasetId, r.actor);
      result.validated = true;
    }
    return result;
  }
}
