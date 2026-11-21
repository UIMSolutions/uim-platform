/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Batch cleansing jobs.
module uim.platform.data_quality.application.usecases.cleansing_jobs;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ManageCleansingJobsUseCase : DqInteractor, IManageCleansingJobs {
  protected CleansingEngine engine;
  protected IManageCleansingRules rules;
  protected ValidateDataUseCase validation;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy,
    IManageCleansingRules rules, ValidateDataUseCase validation) {
    super(repos, clock, events, unitOfWork, policy);
    this.rules = rules;
    this.validation = validation;
    engine = new CleansingEngine;
  }

  CleansingJob createCleansingJob(CreateCleansingJobRequest r) {
    datasetOf(r.tenantId, r.datasetId);
    CleansingJob job;
    stampCreated!(CleansingJob, CleansingJobId)(job, r.tenantId, r.actor, newResourceId(), now);
    job.datasetId = r.datasetId;
    foreach (id; r.ruleIds.map!(s => s.strip).filter!(s => s.length > 0)) {
      rules.getCleansingRule(r.tenantId, CleansingRuleId(id)); // must exist
      if (!job.ruleIds.canFind(CleansingRuleId(id)))
        job.ruleIds ~= CleansingRuleId(id);
    }
    job.dryRun = r.dryRun;
    job.revalidate = r.revalidate;
    repos.cleansingJobs.save(job);
    emit("cleansingJob.created", r.tenantId, resourceKey(r.datasetId.value, job.id.value));
    return policy.runJobsImmediately ? runCleansingJob(r.tenantId, r.datasetId, job.id, r.actor) : job;
  }

  CleansingJob getCleansingJob(TenantId t, DatasetId ds, CleansingJobId id) {
    return required(repos.cleansingJobs.findById(t, ds, id), "Cleansing job '" ~ id.value ~ "'");
  }

  CleansingJob[] listCleansingJobs(TenantId t, DatasetId ds) {
    return repos.cleansingJobs.findByDataset(t, ds);
  }

  CleansingJob runCleansingJob(TenantId t, DatasetId ds, CleansingJobId id, UserId actor) {
    auto job = getCleansingJob(t, ds, id);
    job.start(now);
    stampUpdated(job, actor, now);
    repos.cleansingJobs.save(job);
    try {
      auto selected = selectedRules(t, job);
      job.rulesApplied = selected.length;
      auto refs = new ReferenceData(repos.records, t);
      auto records = repos.records.findByDataset(t, ds);
      job.totalRecords = records.length;
      auto at = now;
      batch(() {
        foreach (record; records) {
          auto outcome = engine.apply(selected, record.fields, refs.lookupDelegate);
          job.processedRecords++;
          if (!outcome.changed)
            continue;
          job.changedRecords++;
          job.changedFields += outcome.changedFields;
          foreach (c; outcome.changes)
            job.log(record.id.value ~ ": " ~ c);
          if (job.dryRun)
            continue;
          record.fields = outcome.fields;
          record.resetValidation();
          stampUpdated(record, actor, at);
          repos.records.save(record);
        }
      });
      job.complete(now);
    } catch (DataQualityException e) {
      job.fail(e.msg, now);
    } catch (Exception e) {
      job.fail("Internal error: " ~ e.msg, now);
    }
    stampUpdated(job, actor, now);
    repos.cleansingJobs.save(job);
    emit("cleansingJob." ~ cast(string) job.status, t, resourceKey(ds.value, id.value), Json([
        "changedRecords": Json(job.changedRecords), "changedFields": Json(job.changedFields), "dryRun": Json(job.dryRun)
      ]));
    if (job.status == JobStatus.completed && job.revalidate && !job.dryRun && job.changedRecords > 0)
      validation.validateDataset(t, ds, actor);
    return job;
  }

  CleansingJob cancelCleansingJob(TenantId t, DatasetId ds, CleansingJobId id, UserId actor) {
    auto job = getCleansingJob(t, ds, id);
    job.cancel(now);
    stampUpdated(job, actor, now);
    repos.cleansingJobs.save(job);
    emit("cleansingJob.cancelled", t, resourceKey(ds.value, id.value));
    return job;
  }

  void deleteCleansingJob(TenantId t, DatasetId ds, CleansingJobId id) {
    auto job = getCleansingJob(t, ds, id);
    if (job.status == JobStatus.running)
      throw DataQualityException.ruleViolation("Cleansing job '" ~ id.value ~ "' is running");
    repos.cleansingJobs.removeById(t, ds, id);
  }

  JobRunSummary runPendingJobs(TenantId t) {
    JobRunSummary s;
    foreach (job; repos.cleansingJobs.findByStatus(t, JobStatus.pending)) {
      s.started++;
      auto done = runCleansingJob(t, job.datasetId, job.id, UserId("system"));
      if (done.status == JobStatus.completed)
        s.completed++;
      else
        s.failed++;
    }
    return s;
  }

  /// The job's rules in execution order (or all applicable active rules).
  protected CleansingRule[] selectedRules(TenantId t, const CleansingJob job) {
    if (job.ruleIds.length == 0)
      return rules.applicableCleansingRules(t, job.datasetId);
    CleansingRule[] selected;
    foreach (id; job.ruleIds) {
      auto rule = repos.cleansingRules.findById(t, id);
      if (rule.isNull)
        throw DataQualityException.notFound("Cleansing rule '" ~ id.value ~ "'");
      selected ~= rule;
    }
    sortRules(selected);
    return selected;
  }
}
