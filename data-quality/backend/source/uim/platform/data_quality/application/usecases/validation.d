/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validation of datasets, single records and ad-hoc records.
module uim.platform.data_quality.application.usecases.validation;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ValidateDataUseCase : DqInteractor, IValidateData {
  protected ValidationEngine engine;
  protected IManageValidationRules rules;
  protected ManageScorecardsUseCase scorecards;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy,
    IManageValidationRules rules, ManageScorecardsUseCase scorecards) {
    super(repos, clock, events, unitOfWork, policy);
    this.rules = rules;
    this.scorecards = scorecards;
    engine = new ValidationEngine;
  }

  ValidationRunResult validateDataset(TenantId t, DatasetId ds, UserId actor) {
    auto started = now;
    auto dataset = datasetOf(t, ds);
    auto applicable = rules.applicableValidationRules(t, ds);
    auto records = repos.records.findByDataset(t, ds);
    auto refs = new ReferenceData(repos.records, t);

    auto checks = new RecordCheck[records.length];
    foreach (i, ref r; records)
      checks[i] = engine.check(applicable, r.fields, refs.containsDelegate);
    mergeUniqueness(applicable, records, checks);

    ValidationRunResult result;
    result.datasetId = ds.value;
    result.records = records.length;
    result.rulesApplied = applicable.length;
    double scoreSum = 0;
    auto at = now;
    batch(() {
      repos.violations.removeByDataset(t, ds);
      foreach (i, ref r; records) {
        foreach (v; toViolations(r, checks[i], actor, at))
          repos.violations.save(v);
        apply(r, checks[i], actor, at);
        repos.records.save(r);
        result.violations += checks[i].findings.length;
        if (checks[i].findings.length == 0)
          result.validRecords++;
        else
          result.invalidRecords++;
        scoreSum += r.qualityScore;
      }
      dataset = repos.datasets.findById(t, ds);
      dataset.validatedAt = at;
      repos.datasets.save(dataset);
    });
    result.averageScore = records.length ? roundScore(scoreSum / records.length) : 100;
    result.scores = scorecards.takeSnapshot(t, ds, actor).scores;
    result.durationMillis = millisBetween(started, now);
    emit("dataset.validated", t, ds.value, Json([
        "records": Json(result.records), "invalid": Json(result.invalidRecords), "violations": Json(result.violations),
        "overall": Json(result.scores.overall)
      ]));
    return result;
  }

  DataRecord validateRecord(TenantId t, DatasetId ds, RecordId id, UserId actor) {
    auto record = recordOf(t, ds, id);
    auto applicable = rules.applicableValidationRules(t, ds);
    auto refs = new ReferenceData(repos.records, t);
    auto check = engine.check(applicable, record.fields, refs.containsDelegate);
    if (applicable.canFind!(r => r.ruleType == RuleType.unique)) {
      auto all = repos.records.findByDataset(t, ds);
      auto checks = new RecordCheck[all.length];
      mergeUniqueness(applicable, all, checks);
      foreach (i, ref r; all)
        if (r.id == id)
          check.findings ~= checks[i].findings;
    }
    auto at = now;
    batch(() {
      repos.violations.removeByRecord(t, ds, id);
      foreach (v; toViolations(record, check, actor, at))
        repos.violations.save(v);
      apply(record, check, actor, at);
      repos.records.save(record);
    });
    auto dataset = repos.datasets.findById(t, ds);
    if (!dataset.isNull && dataset.isScored)
      scorecards.computeScorecard(t, ds, actor);
    return record;
  }

  InlineValidationResult[] validateInline(TenantId t, string datasetId, const InlineRecord[] records) {
    auto applicable = rules.applicableValidationRules(t, DatasetId(datasetId));
    auto refs = new ReferenceData(repos.records, t);
    auto checks = new RecordCheck[records.length];
    FieldValue[][] fields;
    string[] ids;
    foreach (i, r; records) {
      auto f = checkedFields(r.fields);
      fields ~= f;
      ids ~= r.id.length ? r.id : (i + 1).to!string;
      checks[i] = engine.check(applicable, f, refs.containsDelegate);
    }
    foreach (i, findings; engine.checkUniqueness(applicable, fields, ids))
      checks[i].findings ~= findings;
    InlineValidationResult[] result;
    foreach (i, c; checks)
      result ~= InlineValidationResult(ids[i], c);
    return result;
  }

  Violation[] listViolations(TenantId t, DatasetId ds) {
    return repos.violations.findByDataset(t, ds);
  }

  Violation getViolation(TenantId t, DatasetId ds, ViolationId id) {
    return required(repos.violations.findById(t, ds, id), "Violation '" ~ id.value ~ "'");
  }

  // ── internals ────────────────────────────────────────────────────────────

  protected void mergeUniqueness(const ValidationRule[] applicable, const DataRecord[] records, RecordCheck[] checks) {
    if (!applicable.canFind!(r => r.ruleType == RuleType.unique))
      return;
    FieldValue[][] fields;
    string[] ids;
    foreach (r; records) {
      fields ~= r.fields.dup;
      ids ~= r.id.value;
    }
    foreach (i, findings; engine.checkUniqueness(applicable, fields, ids))
      checks[i].findings ~= findings;
  }

  protected static void apply(ref DataRecord r, const RecordCheck check, UserId actor, long at) {
    r.rulesChecked = check.rulesChecked;
    r.violationCount = cast(int) check.findings.length;
    r.qualityScore = check.score;
    r.worstSeverity = check.worstSeverity;
    r.validatedAt = at;
  }

  protected static Violation[] toViolations(const DataRecord r, const RecordCheck check, UserId actor, long at) {
    Violation[] result;
    foreach (f; check.findings) {
      Violation v;
      stampCreated!(Violation, ViolationId)(v, r.tenantId, actor, Violation.idFor(r.id.value, f.ruleId.value), at);
      v.datasetId = r.datasetId;
      v.recordId = r.id;
      v.ruleId = f.ruleId;
      v.ruleName = f.ruleName;
      v.ruleType = f.ruleType;
      v.fieldName = f.fieldName;
      v.fieldValue = clip(f.fieldValue, 500);
      v.severity = f.severity;
      v.message = f.message;
      v.suggestedValue = f.suggestedValue;
      result ~= v;
    }
    return result;
  }
}
