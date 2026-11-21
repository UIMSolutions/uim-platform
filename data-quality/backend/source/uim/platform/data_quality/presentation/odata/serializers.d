/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model).
module uim.platform.data_quality.presentation.odata.serializers;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
Json isoTime(long stdTime) {
  auto text = isoTimeText(stdTime);
  return text.length > 0 ? Json(text) : Json(null);
}

Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Empty text → null (optional values).
Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

private Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

private Json scopedRow(E)(const E e) {
  auto j = auditRow(e);
  j["key"] = resourceKey(e.datasetId.value, e.id.value);
  j["id"] = e.id.value;
  j["datasetId"] = e.datasetId.value;
  return j;
}

void putScores(ref Json j, const QualityScores s) {
  j["overallScore"] = s.overall;
  j["rating"] = cast(string) s.rating;
  j["completeness"] = s.completeness;
  j["validity"] = s.validity;
  j["uniqueness"] = s.uniqueness;
  j["consistency"] = s.consistency;
  j["accuracy"] = s.accuracy;
}

/// Per dataset counters for the Datasets rows.
struct DatasetCounts {
  size_t records;
  size_t invalidRecords;
  size_t violations;
  size_t openDuplicates;
}

Json datasetRow(const Dataset d, DatasetCounts c = DatasetCounts.init) {
  auto j = auditRow(d);
  j["id"] = d.id.value;
  j["name"] = d.name;
  j["description"] = d.description;
  j["category"] = d.category;
  j["recordCount"] = c.records;
  j["invalidRecords"] = c.invalidRecords;
  j["violationCount"] = c.violations;
  j["openDuplicates"] = c.openDuplicates;
  if (d.isScored)
    putScores(j, d.scores);
  else
    foreach (n; ["overallScore", "rating", "completeness", "validity", "uniqueness", "consistency", "accuracy"])
      j[n] = Json(null);
  j["scoredAt"] = isoTime(d.scoredAt);
  j["validatedAt"] = isoTime(d.validatedAt);
  j["profiledAt"] = isoTime(d.profiledAt);
  j["duplicatesCheckedAt"] = isoTime(d.duplicatesCheckedAt);
  return j;
}

/// First non-empty values, e.g. "Ada Lovelace · ada@example.org · London".
string recordSummary(const FieldValue[] fields, size_t count = 3) {
  string[] parts;
  foreach (f; fields)
    if (f.value.strip.length && parts.length < count)
      parts ~= clip(f.value.strip, 40);
  return parts.join(" · ");
}

Json recordRow(const DataRecord r) {
  auto j = scopedRow(r);
  j["fields"] = texts(fieldTexts(r.fields));
  j["summary"] = recordSummary(r.fields);
  j["fieldCount"] = r.fields.length;
  j["qualityScore"] = r.isValidated ? Json(r.qualityScore) : Json(null);
  j["rulesChecked"] = r.rulesChecked;
  j["violationCount"] = r.violationCount;
  j["worstSeverity"] = textOrNull(r.worstSeverity);
  j["validatedAt"] = isoTime(r.validatedAt);
  return j;
}

Json validationRuleRow(const ValidationRule r) {
  auto j = auditRow(r);
  j["id"] = r.id.value;
  j["name"] = r.name;
  j["description"] = r.description;
  j["datasetPattern"] = r.datasetPattern;
  j["fieldName"] = r.fieldName;
  j["ruleType"] = cast(string) r.ruleType;
  j["dimension"] = cast(string) r.dimension;
  j["severity"] = cast(string) r.severity;
  j["status"] = cast(string) r.status;
  j["pattern"] = r.pattern;
  j["minValue"] = r.minValue;
  j["maxValue"] = r.maxValue;
  j["allowedValues"] = texts(r.allowedValues);
  j["caseSensitive"] = r.caseSensitive;
  j["crossFieldName"] = r.crossFieldName;
  j["operator"] = r.operator;
  j["expression"] = r.expression;
  j["referenceDataset"] = r.referenceDataset;
  j["referenceField"] = r.referenceField;
  j["category"] = r.category;
  j["priority"] = r.priority;
  return j;
}

Json violationRow(const Violation v) {
  auto j = scopedRow(v);
  j["recordId"] = v.recordId.value;
  j["recordKey"] = resourceKey(v.datasetId.value, v.recordId.value);
  j["ruleId"] = v.ruleId.value;
  j["ruleName"] = v.ruleName;
  j["ruleType"] = cast(string) v.ruleType;
  j["dimension"] = cast(string) v.dimension;
  j["fieldName"] = v.fieldName;
  j["fieldValue"] = v.fieldValue;
  j["severity"] = cast(string) v.severity;
  j["message"] = v.message;
  j["suggestedValue"] = textOrNull(v.suggestedValue);
  return j;
}

Json cleansingRuleRow(const CleansingRule r) {
  auto j = auditRow(r);
  j["id"] = r.id.value;
  j["name"] = r.name;
  j["description"] = r.description;
  j["datasetPattern"] = r.datasetPattern;
  j["fieldName"] = r.fieldName;
  j["action"] = cast(string) r.action;
  j["status"] = cast(string) r.status;
  j["findPattern"] = r.findPattern;
  j["replaceWith"] = r.replaceWith;
  j["defaultValue"] = r.defaultValue;
  j["lookupDataset"] = r.lookupDataset;
  j["lookupKeyField"] = r.lookupKeyField;
  j["lookupValueField"] = r.lookupValueField;
  j["sourceField"] = r.sourceField;
  j["category"] = r.category;
  j["priority"] = r.priority;
  return j;
}

Json cleansingJobRow(const CleansingJob job) {
  auto j = scopedRow(job);
  j["ruleIds"] = texts(job.ruleIds.map!(r => r.value).array);
  j["dryRun"] = job.dryRun;
  j["revalidate"] = job.revalidate;
  j["status"] = cast(string) job.status;
  j["totalRecords"] = job.totalRecords;
  j["processedRecords"] = job.processedRecords;
  j["changedRecords"] = job.changedRecords;
  j["changedFields"] = job.changedFields;
  j["rulesApplied"] = job.rulesApplied;
  j["errorMessage"] = textOrNull(job.errorMessage);
  j["changeLog"] = texts(job.changeLog);
  j["startedAt"] = isoTime(job.startedAt);
  j["completedAt"] = isoTime(job.completedAt);
  j["durationMillis"] = job.durationMillis;
  return j;
}

string candidateText(const MatchCandidate c) {
  return c.recordId.value ~ "=" ~ format("%g", c.score);
}

Json matchGroupRow(const MatchGroup g) {
  auto j = scopedRow(g);
  j["strategy"] = cast(string) g.strategy;
  j["threshold"] = g.threshold;
  j["matchFields"] = texts(g.matchFields);
  j["candidates"] = texts(g.candidates.map!(c => candidateText(c)).array);
  j["size"] = g.size;
  j["bestScore"] = g.bestScore;
  j["survivorRecordId"] = g.survivorRecordId.value;
  j["resolved"] = g.resolved;
  j["detectedAt"] = isoTime(g.detectedAt);
  j["resolvedAt"] = isoTime(g.resolvedAt);
  return j;
}

Json columnProfileRow(const ColumnProfile p) {
  auto j = scopedRow(p);
  auto s = p.stats;
  j["position"] = p.position;
  j["detectedType"] = cast(string) s.detectedType;
  j["totalValues"] = s.totalValues;
  j["missingCount"] = s.missingCount;
  j["distinctCount"] = s.distinctCount;
  j["duplicateCount"] = s.duplicateCount;
  j["completeness"] = s.completeness;
  j["uniqueness"] = s.uniqueness;
  j["minValue"] = textOrNull(s.minValue);
  j["maxValue"] = textOrNull(s.maxValue);
  j["mean"] = s.numeric ? Json(s.mean) : Json(null);
  j["numeric"] = s.numeric;
  j["minLength"] = s.minLength;
  j["maxLength"] = s.maxLength;
  j["avgLength"] = s.avgLength;
  j["topValues"] = texts(s.topValues);
  j["patterns"] = texts(s.patterns);
  j["profiledAt"] = isoTime(p.profiledAt);
  return j;
}

/// Column statistics without persistence context (REST /profiles).
Json columnStatsJson(const ColumnStats s) {
  ColumnProfile p;
  p.stats = (() @trusted => cast(ColumnStats) s)();
  auto j = columnProfileRow(p);
  foreach (n; ["key", "id", "datasetId", "tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy", "profiledAt", "position"])
    j.remove(n);
  j["fieldName"] = s.fieldName;
  return j;
}

Json addressRow(const PostalAddress a) {
  auto j = auditRow(a);
  j["id"] = a.id.value;
  j["sourceRecordId"] = a.sourceRecordId;
  j["inputLine1"] = a.input.line1;
  j["inputLine2"] = a.input.line2;
  j["inputCity"] = a.input.city;
  j["inputRegion"] = a.input.region;
  j["inputPostalCode"] = a.input.postalCode;
  j["inputCountry"] = a.input.country;
  j["line1"] = a.output.line1;
  j["line2"] = a.output.line2;
  j["city"] = a.output.city;
  j["region"] = a.output.region;
  j["postalCode"] = a.output.postalCode;
  j["country"] = a.output.country;
  j["countryRecognized"] = a.output.countryRecognized;
  j["postalCodePlausible"] = a.output.postalCodePlausible;
  j["quality"] = cast(string) a.output.quality;
  j["changes"] = texts(a.output.changes);
  j["cleansedAt"] = isoTime(a.cleansedAt);
  return j;
}

Json snapshotRow(const QualitySnapshot s) {
  auto j = scopedRow(s);
  putScores(j, s.scores);
  j["recordCount"] = s.recordCount;
  j["violationCount"] = s.violationCount;
  j["takenAt"] = isoTime(s.takenAt);
  return j;
}

Json statisticsRow(const DqStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId;
  j["datasets"] = s.datasets;
  j["scoredDatasets"] = s.scoredDatasets;
  j["records"] = s.records;
  j["validatedRecords"] = s.validatedRecords;
  j["invalidRecords"] = s.invalidRecords;
  j["validationRules"] = s.validationRules;
  j["activeValidationRules"] = s.activeValidationRules;
  j["violations"] = s.violations;
  j["criticalViolations"] = s.criticalViolations;
  j["errorViolations"] = s.errorViolations;
  j["warningViolations"] = s.warningViolations;
  j["cleansingRules"] = s.cleansingRules;
  j["activeCleansingRules"] = s.activeCleansingRules;
  j["cleansingJobs"] = s.cleansingJobs;
  j["pendingJobs"] = s.pendingJobs;
  j["failedJobs"] = s.failedJobs;
  j["matchGroups"] = s.matchGroups;
  j["openMatchGroups"] = s.openMatchGroups;
  j["duplicateRecords"] = s.duplicateRecords;
  j["addresses"] = s.addresses;
  j["verifiedAddresses"] = s.verifiedAddresses;
  j["invalidAddresses"] = s.invalidAddresses;
  j["averageScore"] = s.averageScore;
  j["rating"] = cast(string) s.rating;
  j["computedAt"] = isoTime(s.computedAt);
  return j;
}

// ── action results ─────────────────────────────────────────────────────────

Json validationRunRow(const ValidationRunResult r) {
  auto j = Json.emptyObject;
  j["datasetId"] = r.datasetId;
  j["records"] = r.records;
  j["validRecords"] = r.validRecords;
  j["invalidRecords"] = r.invalidRecords;
  j["violations"] = r.violations;
  j["rulesApplied"] = r.rulesApplied;
  j["averageScore"] = r.averageScore;
  j["durationMillis"] = r.durationMillis;
  putScores(j, r.scores);
  return j;
}

Json recordValidationRow(const DataRecord r) {
  auto j = Json.emptyObject;
  j["key"] = resourceKey(r.datasetId.value, r.id.value);
  j["qualityScore"] = r.qualityScore;
  j["rulesChecked"] = r.rulesChecked;
  j["violationCount"] = r.violationCount;
  j["worstSeverity"] = r.worstSeverity;
  return j;
}

Json profileRunRow(const ProfileRunResult r) {
  auto j = Json.emptyObject;
  j["datasetId"] = r.datasetId;
  j["records"] = r.records;
  j["columns"] = r.columns;
  j["completeness"] = r.completeness;
  j["uniqueness"] = r.uniqueness;
  j["durationMillis"] = r.durationMillis;
  return j;
}

Json detectRow(const DetectResult r) {
  auto j = Json.emptyObject;
  j["datasetId"] = r.datasetId;
  j["records"] = r.records;
  j["groups"] = r.groups;
  j["duplicateRecords"] = r.duplicateRecords;
  j["strategy"] = r.strategy;
  j["threshold"] = r.threshold;
  j["durationMillis"] = r.durationMillis;
  return j;
}

Json resolveRow(const ResolveResult r) {
  auto j = Json.emptyObject;
  j["datasetId"] = r.datasetId;
  j["matchGroupId"] = r.matchGroupId;
  j["survivorRecordId"] = r.survivorRecordId;
  j["removedRecords"] = r.removedRecords;
  j["mergedFields"] = r.mergedFields;
  return j;
}

Json scorecardRow(const Scorecard c) {
  auto j = Json.emptyObject;
  j["datasetId"] = c.datasetId;
  j["records"] = c.records;
  j["violations"] = c.violations;
  j["openDuplicates"] = c.openDuplicates;
  j["computedAt"] = isoTime(c.computedAt);
  putScores(j, c.scores);
  return j;
}

Json jobResultRow(const CleansingJob job) {
  auto j = Json.emptyObject;
  j["key"] = resourceKey(job.datasetId.value, job.id.value);
  j["id"] = job.id.value;
  j["status"] = cast(string) job.status;
  j["changedRecords"] = job.changedRecords;
  j["changedFields"] = job.changedFields;
  j["errorMessage"] = job.errorMessage;
  return j;
}

Json importRow(const ImportResult r) {
  auto j = Json.emptyObject;
  j["datasetId"] = r.datasetId;
  j["datasetCreated"] = r.datasetCreated;
  j["created"] = r.created;
  j["updated"] = r.updated;
  j["skipped"] = r.skipped;
  j["validated"] = r.validated;
  j["violations"] = r.validation.violations;
  j["overallScore"] = r.validated ? Json(r.validation.scores.overall) : Json(null);
  return j;
}

Json seedRow(const SeedResult s) {
  auto j = Json.emptyObject;
  j["datasets"] = s.datasets;
  j["records"] = s.records;
  j["validationRules"] = s.validationRules;
  j["cleansingRules"] = s.cleansingRules;
  j["addresses"] = s.addresses;
  j["violations"] = s.violations;
  j["matchGroups"] = s.matchGroups;
  j["cleansingJobs"] = s.cleansingJobs;
  return j;
}

/// A record check (REST /validate).
Json recordCheckJson(string recordId, const RecordCheck c) {
  auto j = Json.emptyObject;
  j["recordId"] = recordId;
  j["rulesChecked"] = c.rulesChecked;
  j["qualityScore"] = c.score;
  j["valid"] = c.findings.length == 0;
  j["worstSeverity"] = textOrNull(c.worstSeverity);
  auto findings = Json.emptyArray;
  foreach (f; c.findings) {
    auto v = Json.emptyObject;
    v["ruleId"] = f.ruleId.value;
    v["ruleName"] = f.ruleName;
    v["ruleType"] = cast(string) f.ruleType;
    v["dimension"] = cast(string) dimensionOf(f.ruleType);
    v["fieldName"] = f.fieldName;
    v["fieldValue"] = f.fieldValue;
    v["severity"] = cast(string) f.severity;
    v["message"] = f.message;
    v["suggestedValue"] = textOrNull(f.suggestedValue);
    findings ~= v;
  }
  j["violations"] = findings;
  return j;
}

/// A detected group (REST /duplicates/detect).
Json detectedGroupJson(const DetectedGroup g) {
  auto candidates = Json.emptyArray;
  foreach (c; g.candidates) {
    auto j = Json.emptyObject;
    j["recordId"] = c.recordId.value;
    j["score"] = c.score;
    j["confidence"] = cast(string) c.confidence;
    candidates ~= j;
  }
  return Json(["candidates": candidates, "size": Json(g.candidates.length)]);
}
