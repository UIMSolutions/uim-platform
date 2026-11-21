/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Duplicate detection and golden record resolution.
module uim.platform.data_quality.application.usecases.duplicates;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class DetectDuplicatesUseCase : DqInteractor, IDetectDuplicates {
  protected DuplicateDetector detector;
  protected ValidateDataUseCase validation;
  protected ManageScorecardsUseCase scorecards;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy,
    ValidateDataUseCase validation, ManageScorecardsUseCase scorecards) {
    super(repos, clock, events, unitOfWork, policy);
    this.validation = validation;
    this.scorecards = scorecards;
    detector = new DuplicateDetector;
  }

  DetectResult detectDuplicates(DetectDuplicatesRequest r) {
    auto started = now;
    datasetOf(r.tenantId, r.datasetId);
    auto fields = checkedMatchFields(r.matchFields);
    auto strategy = parseDomainEnumOr!MatchStrategy(r.strategy, MatchStrategy.fuzzy, "strategy");
    auto threshold = checkedThreshold(r.threshold, strategy);
    auto records = repos.records.findByDataset(r.tenantId, r.datasetId);
    checkSize(records.length, strategy);

    MatchInput[] inputs;
    foreach (rec; records)
      inputs ~= MatchInput(rec.id, rec.fields);
    auto detected = detector.detect(inputs, fields, strategy, threshold);
    auto at = now;

    DetectResult result;
    result.datasetId = r.datasetId.value;
    result.records = records.length;
    result.strategy = cast(string) strategy;
    result.threshold = threshold;
    batch(() {
      // replace the open groups, keep the resolved ones (and skip re-detecting them)
      string[] resolvedSets;
      foreach (g; repos.matchGroups.findByDataset(r.tenantId, r.datasetId)) {
        if (g.resolved)
          resolvedSets ~= memberKey(g.candidates);
        else
          repos.matchGroups.removeById(r.tenantId, r.datasetId, g.id);
      }
      foreach (d; detected) {
        if (resolvedSets.canFind(memberKey(d.candidates)))
          continue;
        MatchGroup g;
        stampCreated!(MatchGroup, MatchGroupId)(g, r.tenantId, r.actor, newResourceId(), at);
        g.datasetId = r.datasetId;
        g.strategy = strategy;
        g.threshold = threshold;
        g.matchFields = fields;
        g.candidates = d.candidates;
        g.survivorRecordId = d.candidates[0].recordId;
        g.detectedAt = at;
        repos.matchGroups.save(g);
        result.groups++;
        result.duplicateRecords += g.duplicates.length;
      }
      auto ds = repos.datasets.findById(r.tenantId, r.datasetId);
      ds.duplicatesCheckedAt = at;
      repos.datasets.save(ds);
    });
    scorecards.computeScorecard(r.tenantId, r.datasetId, r.actor);
    result.durationMillis = millisBetween(started, now);
    emit("duplicates.detected", r.tenantId, r.datasetId.value, Json([
        "groups": Json(result.groups), "duplicates": Json(result.duplicateRecords), "strategy": Json(result.strategy)
      ]));
    return result;
  }

  DetectedGroup[] detectInline(const InlineRecord[] records, const string[] matchFields, string strategyText, double threshold) {
    auto fields = checkedMatchFields(matchFields);
    auto strategy = parseDomainEnumOr!MatchStrategy(strategyText, MatchStrategy.fuzzy, "strategy");
    checkSize(records.length, strategy);
    MatchInput[] inputs;
    foreach (i, r; records)
      inputs ~= MatchInput(RecordId(r.id.length ? r.id : (i + 1).to!string), checkedFields(r.fields));
    return detector.detect(inputs, fields, strategy, checkedThreshold(threshold, strategy));
  }

  MatchGroup[] listMatchGroups(TenantId t, DatasetId ds) {
    return repos.matchGroups.findByDataset(t, ds);
  }

  MatchGroup getMatchGroup(TenantId t, DatasetId ds, MatchGroupId id) {
    return required(repos.matchGroups.findById(t, ds, id), "Match group '" ~ id.value ~ "'");
  }

  ResolveResult resolveMatchGroup(ResolveMatchGroupRequest r) {
    auto g = getMatchGroup(r.tenantId, r.datasetId, MatchGroupId(r.id));
    auto survivor = RecordId(r.survivorRecordId.strip.length ? r.survivorRecordId.strip : g.candidates[0].recordId.value);
    auto at = now;
    g.resolve(survivor, at);
    stampUpdated(g, r.actor, at);

    ResolveResult result;
    result.datasetId = r.datasetId.value;
    result.matchGroupId = g.id.value;
    result.survivorRecordId = survivor.value;
    bool survivorChanged;
    batch(() {
      if (r.merge) {
        auto golden = recordOf(r.tenantId, r.datasetId, survivor);
        foreach (dup; g.duplicates) {
          auto other = repos.records.findById(r.tenantId, r.datasetId, dup);
          if (other.isNull)
            continue;
          foreach (f; other.fields)
            if (f.value.strip.length && golden.field(f.name).strip.length == 0) {
              golden.fields = withField(golden.fields, f.name, f.value);
              result.mergedFields++;
            }
          repos.violations.removeByRecord(r.tenantId, r.datasetId, dup);
          repos.records.removeById(r.tenantId, r.datasetId, dup);
          result.removedRecords++;
        }
        if (result.mergedFields > 0) {
          golden.resetValidation();
          stampUpdated(golden, r.actor, at);
          repos.records.save(golden);
          survivorChanged = true;
        }
      }
      repos.matchGroups.save(g);
    });
    if (survivorChanged && policy.autoValidate)
      validation.validateRecord(r.tenantId, r.datasetId, survivor, r.actor);
    scorecards.computeScorecard(r.tenantId, r.datasetId, r.actor);
    emit("matchGroup.resolved", r.tenantId, resourceKey(r.datasetId.value, g.id.value), Json([
        "survivor": Json(survivor.value), "removed": Json(result.removedRecords)
      ]));
    return result;
  }

  void deleteMatchGroup(TenantId t, DatasetId ds, MatchGroupId id) {
    getMatchGroup(t, ds, id);
    repos.matchGroups.removeById(t, ds, id);
  }

  // ── internals ────────────────────────────────────────────────────────────

  protected static string[] checkedMatchFields(const string[] fields) {
    string[] result;
    foreach (f; fields) {
      auto name = f.strip;
      if (name.length == 0)
        continue;
      requireFieldName(name, "Match field");
      if (!result.canFind(name))
        result ~= name;
    }
    if (result.length == 0)
      throw DataQualityException.invalid("At least one match field is required");
    return result;
  }

  protected static double checkedThreshold(double threshold, MatchStrategy strategy) {
    if (strategy == MatchStrategy.exact || strategy == MatchStrategy.phonetic)
      return 100;
    requireRange(threshold, 50, 100, "Threshold");
    return threshold;
  }

  protected void checkSize(size_t records, MatchStrategy strategy) {
    if ((strategy == MatchStrategy.fuzzy || strategy == MatchStrategy.composite) && records > policy.maxPairwiseRecords)
      throw DataQualityException.ruleViolation(format("Fuzzy matching is limited to %d records (use exact or phonetic)",
          policy.maxPairwiseRecords));
  }

  protected static string memberKey(const MatchCandidate[] candidates) {
    string[] ids;
    foreach (c; candidates)
      ids ~= c.recordId.value;
    return ids.sort.release.join(",");
  }
}
