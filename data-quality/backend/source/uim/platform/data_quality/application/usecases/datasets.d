/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.datasets;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ManageDatasetsUseCase : DqInteractor, IManageDatasets {
  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  Dataset createDataset(CreateDatasetRequest r) {
    auto id = r.id.strip;
    requireId(id, "Dataset ID");
    if (repos.datasets.existsById(r.tenantId, DatasetId(id)))
      throw DataQualityException.conflict("Dataset '" ~ id ~ "' already exists");
    Dataset d;
    stampCreated!(Dataset, DatasetId)(d, r.tenantId, r.actor, id, now);
    d.name = r.name.strip.length ? r.name.strip : id;
    d.description = r.description;
    d.category = r.category.strip;
    d.validate();
    repos.datasets.save(d);
    emit("dataset.created", r.tenantId, id);
    return d;
  }

  Dataset updateDataset(UpdateDatasetRequest r) {
    auto d = getDataset(r.tenantId, DatasetId(r.id));
    r.name.applyTo(d.name);
    r.description.applyTo(d.description);
    r.category.applyTo(d.category);
    d.name = d.name.strip;
    d.validate();
    stampUpdated(d, r.actor, now);
    repos.datasets.save(d);
    return d;
  }

  Dataset getDataset(TenantId t, DatasetId id) {
    return datasetOf(t, id);
  }

  Dataset[] listDatasets(TenantId t) {
    return repos.datasets.findAll(t);
  }

  void deleteDataset(TenantId t, DatasetId id, UserId actor) {
    datasetOf(t, id);
    foreach (rule; repos.validationRules.findAll(t))
      if (rule.ruleType == RuleType.referenceData && rule.referenceDataset == id.value)
        throw DataQualityException.ruleViolation("Dataset '" ~ id.value ~ "' is reference data of validation rule '" ~ rule.name ~ "'");
    foreach (rule; repos.cleansingRules.findAll(t))
      if (rule.action == CleansingAction.enrich && rule.lookupDataset == id.value)
        throw DataQualityException.ruleViolation("Dataset '" ~ id.value ~ "' is the lookup dataset of cleansing rule '" ~ rule.name ~ "'");
    foreach (job; repos.cleansingJobs.findByDataset(t, id))
      if (job.status == JobStatus.running)
        throw DataQualityException.ruleViolation("Cleansing job '" ~ job.id.value ~ "' of dataset '" ~ id.value ~ "' is running");
    size_t records;
    batch(() {
      records = repos.records.removeByDataset(t, id);
      repos.violations.removeByDataset(t, id);
      repos.columnProfiles.removeByDataset(t, id);
      repos.matchGroups.removeByDataset(t, id);
      repos.snapshots.removeByDataset(t, id);
      repos.cleansingJobs.removeByDataset(t, id);
      repos.datasets.removeById(t, id);
    });
    emit("dataset.deleted", t, id.value, Json(["records": Json(records), "by": Json(actor.value)]));
  }
}
