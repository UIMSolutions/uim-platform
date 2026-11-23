/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mappers.
module uim.platform.data_quality.persistence.mappers.entities;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

// ── Dataset ─────────────────────────────────────────────────────────────────
Json datasetToRecord(const Dataset e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["category"] = e.category;
  d["scores"] = scoresRecord(e.scores);
  d["scoredAt"] = e.scoredAt;
  d["validatedAt"] = e.validatedAt;
  d["profiledAt"] = e.profiledAt;
  d["duplicatesCheckedAt"] = e.duplicatesCheckedAt;
  return d;
}

Dataset recordToDataset(Json d) {
  Dataset e;
  readAudit!(Dataset, DatasetId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.category = textField(d, "category");
  e.scores = scoresField(d, "scores");
  e.scoredAt = longField(d, "scoredAt");
  e.validatedAt = longField(d, "validatedAt");
  e.profiledAt = longField(d, "profiledAt");
  e.duplicatesCheckedAt = longField(d, "duplicatesCheckedAt");
  return e;
}

// ── DataRecord ──────────────────────────────────────────────────────────────
Json recordToDocument(const DataRecord e) {
  auto d = auditRecord(e);
  d["datasetId"] = e.datasetId.value;
  d["fields"] = fieldsRecord(e.fields);
  d["qualityScore"] = e.qualityScore;
  d["rulesChecked"] = e.rulesChecked;
  d["violationCount"] = e.violationCount;
  d["worstSeverity"] = e.worstSeverity;
  d["validatedAt"] = e.validatedAt;
  return d;
}

DataRecord documentToRecord(Json d) {
  DataRecord e;
  readAudit!(DataRecord, RecordId)(e, d);
  e.datasetId = DatasetId(textField(d, "datasetId"));
  e.fields = fieldsField(d, "fields");
  e.qualityScore = doubleField(d, "qualityScore", 100);
  e.rulesChecked = cast(int) longField(d, "rulesChecked");
  e.violationCount = cast(int) longField(d, "violationCount");
  e.worstSeverity = textField(d, "worstSeverity");
  e.validatedAt = longField(d, "validatedAt");
  return e;
}

// ── ValidationRule ──────────────────────────────────────────────────────────
Json validationRuleToRecord(const ValidationRule e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["datasetPattern"] = e.datasetPattern;
  d["fieldName"] = e.fieldName;
  d["ruleType"] = cast(string) e.ruleType;
  d["severity"] = cast(string) e.severity;
  d["status"] = cast(string) e.status;
  d["pattern"] = e.pattern;
  d["minValue"] = e.minValue;
  d["maxValue"] = e.maxValue;
  d["allowedValues"] = textsRecord(e.allowedValues);
  d["caseSensitive"] = e.caseSensitive;
  d["crossFieldName"] = e.crossFieldName;
  d["operator"] = e.operator;
  d["expression"] = e.expression;
  d["referenceDataset"] = e.referenceDataset;
  d["referenceField"] = e.referenceField;
  d["category"] = e.category;
  d["priority"] = e.priority;
  return d;
}

ValidationRule recordToValidationRule(Json d) {
  ValidationRule e;
  readAudit!(ValidationRule, ValidationRuleId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.datasetPattern = textField(d, "datasetPattern");
  e.fieldName = textField(d, "fieldName");
  e.ruleType = domainEnumOr!RuleType(textField(d, "ruleType"), RuleType.required);
  e.severity = domainEnumOr!RuleSeverity(textField(d, "severity"), RuleSeverity.error);
  e.status = domainEnumOr!RuleStatus(textField(d, "status"), RuleStatus.draft);
  e.pattern = textField(d, "pattern");
  e.minValue = textField(d, "minValue");
  e.maxValue = textField(d, "maxValue");
  e.allowedValues = textsField(d, "allowedValues");
  e.caseSensitive = boolField(d, "caseSensitive", true);
  e.crossFieldName = textField(d, "crossFieldName");
  e.operator = textField(d, "operator").length ? textField(d, "operator") : "eq";
  e.expression = textField(d, "expression");
  e.referenceDataset = textField(d, "referenceDataset");
  e.referenceField = textField(d, "referenceField");
  e.category = textField(d, "category");
  e.priority = cast(int) longField(d, "priority", 100);
  return e;
}

// ── Violation ───────────────────────────────────────────────────────────────
Json violationToRecord(const Violation e) {
  auto d = auditRecord(e);
  d["datasetId"] = e.datasetId.value;
  d["recordId"] = e.recordId.value;
  d["ruleId"] = e.ruleId.value;
  d["ruleName"] = e.ruleName;
  d["ruleType"] = cast(string) e.ruleType;
  d["fieldName"] = e.fieldName;
  d["fieldValue"] = e.fieldValue;
  d["severity"] = cast(string) e.severity;
  d["message"] = e.message;
  d["suggestedValue"] = e.suggestedValue;
  return d;
}

Violation recordToViolation(Json d) {
  Violation e;
  readAudit!(Violation, ViolationId)(e, d);
  e.datasetId = DatasetId(textField(d, "datasetId"));
  e.recordId = RecordId(textField(d, "recordId"));
  e.ruleId = ValidationRuleId(textField(d, "ruleId"));
  e.ruleName = textField(d, "ruleName");
  e.ruleType = domainEnumOr!RuleType(textField(d, "ruleType"), RuleType.custom);
  e.fieldName = textField(d, "fieldName");
  e.fieldValue = textField(d, "fieldValue");
  e.severity = domainEnumOr!RuleSeverity(textField(d, "severity"), RuleSeverity.error);
  e.message = textField(d, "message");
  e.suggestedValue = textField(d, "suggestedValue");
  return e;
}

// ── CleansingRule ───────────────────────────────────────────────────────────
Json cleansingRuleToRecord(const CleansingRule e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["datasetPattern"] = e.datasetPattern;
  d["fieldName"] = e.fieldName;
  d["action"] = cast(string) e.action;
  d["status"] = cast(string) e.status;
  d["findPattern"] = e.findPattern;
  d["replaceWith"] = e.replaceWith;
  d["defaultValue"] = e.defaultValue;
  d["lookupDataset"] = e.lookupDataset;
  d["lookupKeyField"] = e.lookupKeyField;
  d["lookupValueField"] = e.lookupValueField;
  d["sourceField"] = e.sourceField;
  d["category"] = e.category;
  d["priority"] = e.priority;
  return d;
}

CleansingRule recordToCleansingRule(Json d) {
  CleansingRule e;
  readAudit!(CleansingRule, CleansingRuleId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.datasetPattern = textField(d, "datasetPattern");
  e.fieldName = textField(d, "fieldName");
  e.action = domainEnumOr!CleansingAction(textField(d, "action"), CleansingAction.trim);
  e.status = domainEnumOr!RuleStatus(textField(d, "status"), RuleStatus.draft);
  e.findPattern = textField(d, "findPattern");
  e.replaceWith = textField(d, "replaceWith");
  e.defaultValue = textField(d, "defaultValue");
  e.lookupDataset = textField(d, "lookupDataset");
  e.lookupKeyField = textField(d, "lookupKeyField");
  e.lookupValueField = textField(d, "lookupValueField");
  e.sourceField = textField(d, "sourceField");
  e.category = textField(d, "category");
  e.priority = cast(int) longField(d, "priority", 100);
  return e;
}

// ── CleansingJob ────────────────────────────────────────────────────────────
Json cleansingJobToRecord(const CleansingJob e) {
  auto d = auditRecord(e);
  d["datasetId"] = e.datasetId.value;
  d["ruleIds"] = textsRecord(e.ruleIds.map!(r => r.value).array);
  d["dryRun"] = e.dryRun;
  d["revalidate"] = e.revalidate;
  d["status"] = cast(string) e.status;
  d["totalRecords"] = e.totalRecords;
  d["processedRecords"] = e.processedRecords;
  d["changedRecords"] = e.changedRecords;
  d["changedFields"] = e.changedFields;
  d["rulesApplied"] = e.rulesApplied;
  d["errorMessage"] = e.errorMessage;
  d["changeLog"] = textsRecord(e.changeLog);
  d["startedAt"] = e.startedAt;
  d["completedAt"] = e.completedAt;
  return d;
}

CleansingJob recordToCleansingJob(Json d) {
  CleansingJob e;
  readAudit!(CleansingJob, CleansingJobId)(e, d);
  e.datasetId = DatasetId(textField(d, "datasetId"));
  e.ruleIds = textsField(d, "ruleIds").map!(s => CleansingRuleId(s)).array;
  e.dryRun = boolField(d, "dryRun");
  e.revalidate = boolField(d, "revalidate", true);
  e.status = domainEnumOr!JobStatus(textField(d, "status"), JobStatus.pending);
  e.totalRecords = longField(d, "totalRecords");
  e.processedRecords = longField(d, "processedRecords");
  e.changedRecords = longField(d, "changedRecords");
  e.changedFields = longField(d, "changedFields");
  e.rulesApplied = longField(d, "rulesApplied");
  e.errorMessage = textField(d, "errorMessage");
  e.changeLog = textsField(d, "changeLog");
  e.startedAt = longField(d, "startedAt");
  e.completedAt = longField(d, "completedAt");
  return e;
}

// ── MatchGroup ──────────────────────────────────────────────────────────────
Json matchGroupToRecord(const MatchGroup e) {
  auto d = auditRecord(e);
  d["datasetId"] = e.datasetId.value;
  d["strategy"] = cast(string) e.strategy;
  d["threshold"] = e.threshold;
  d["matchFields"] = textsRecord(e.matchFields);
  auto candidates = Json.emptyArray;
  foreach (c; e.candidates) {
    auto j = Json.emptyObject;
    j["recordId"] = c.recordId.value;
    j["score"] = c.score;
    j["confidence"] = cast(string) c.confidence;
    candidates ~= j;
  }
  d["candidates"] = candidates;
  d["survivorRecordId"] = e.survivorRecordId.value;
  d["resolved"] = e.resolved;
  d["detectedAt"] = e.detectedAt;
  d["resolvedAt"] = e.resolvedAt;
  return d;
}

MatchGroup recordToMatchGroup(Json d) {
  MatchGroup e;
  readAudit!(MatchGroup, MatchGroupId)(e, d);
  e.datasetId = DatasetId(textField(d, "datasetId"));
  e.strategy = domainEnumOr!MatchStrategy(textField(d, "strategy"), MatchStrategy.fuzzy);
  e.threshold = doubleField(d, "threshold", 85);
  e.matchFields = textsField(d, "matchFields");
  foreach (o; objectsField(d, "candidates"))
    e.candidates ~= MatchCandidate(RecordId(textField(o, "recordId")), doubleField(o, "score"),
      domainEnumOr!MatchConfidence(textField(o, "confidence"), MatchConfidence.low));
  e.survivorRecordId = RecordId(textField(d, "survivorRecordId"));
  e.resolved = boolField(d, "resolved");
  e.detectedAt = longField(d, "detectedAt");
  e.resolvedAt = longField(d, "resolvedAt");
  return e;
}

// ── ColumnProfile ───────────────────────────────────────────────────────────
Json columnProfileToRecord(const ColumnProfile e) {
  auto d = auditRecord(e);
  auto s = e.stats;
  d["datasetId"] = e.datasetId.value;
  d["position"] = e.position;
  d["fieldName"] = s.fieldName;
  d["detectedType"] = cast(string) s.detectedType;
  d["totalValues"] = s.totalValues;
  d["missingCount"] = s.missingCount;
  d["distinctCount"] = s.distinctCount;
  d["duplicateCount"] = s.duplicateCount;
  d["completeness"] = s.completeness;
  d["uniqueness"] = s.uniqueness;
  d["minValue"] = s.minValue;
  d["maxValue"] = s.maxValue;
  d["mean"] = s.mean;
  d["numeric"] = s.numeric;
  d["minLength"] = s.minLength;
  d["maxLength"] = s.maxLength;
  d["avgLength"] = s.avgLength;
  d["topValues"] = textsRecord(s.topValues);
  d["patterns"] = textsRecord(s.patterns);
  d["profiledAt"] = e.profiledAt;
  return d;
}

ColumnProfile recordToColumnProfile(Json d) {
  ColumnProfile e;
  readAudit!(ColumnProfile, ColumnProfileId)(e, d);
  e.datasetId = DatasetId(textField(d, "datasetId"));
  e.position = cast(int) longField(d, "position");
  e.stats.fieldName = textField(d, "fieldName");
  e.stats.detectedType = domainEnumOr!ProfiledType(textField(d, "detectedType"), ProfiledType.text);
  e.stats.totalValues = longField(d, "totalValues");
  e.stats.missingCount = longField(d, "missingCount");
  e.stats.distinctCount = longField(d, "distinctCount");
  e.stats.duplicateCount = longField(d, "duplicateCount");
  e.stats.completeness = doubleField(d, "completeness", 100);
  e.stats.uniqueness = doubleField(d, "uniqueness", 100);
  e.stats.minValue = textField(d, "minValue");
  e.stats.maxValue = textField(d, "maxValue");
  e.stats.mean = doubleField(d, "mean");
  e.stats.numeric = boolField(d, "numeric");
  e.stats.minLength = longField(d, "minLength");
  e.stats.maxLength = longField(d, "maxLength");
  e.stats.avgLength = doubleField(d, "avgLength");
  e.stats.topValues = textsField(d, "topValues");
  e.stats.patterns = textsField(d, "patterns");
  e.profiledAt = longField(d, "profiledAt");
  return e;
}

// ── PostalAddress ─────────────────────────────────────────────────────────────────
Json addressToRecord(const PostalAddress e) {
  auto d = auditRecord(e);
  d["sourceRecordId"] = e.sourceRecordId;
  auto i = Json.emptyObject;
  i["line1"] = e.input.line1;
  i["line2"] = e.input.line2;
  i["city"] = e.input.city;
  i["region"] = e.input.region;
  i["postalCode"] = e.input.postalCode;
  i["country"] = e.input.country;
  d["input"] = i;
  auto o = Json.emptyObject;
  o["line1"] = e.output.line1;
  o["line2"] = e.output.line2;
  o["city"] = e.output.city;
  o["region"] = e.output.region;
  o["postalCode"] = e.output.postalCode;
  o["country"] = e.output.country;
  o["countryRecognized"] = e.output.countryRecognized;
  o["postalCodePlausible"] = e.output.postalCodePlausible;
  o["quality"] = cast(string) e.output.quality;
  o["changes"] = textsRecord(e.output.changes);
  d["output"] = o;
  d["cleansedAt"] = e.cleansedAt;
  return d;
}

PostalAddress recordToAddress(Json d) {
  PostalAddress e;
  readAudit!(PostalAddress, AddressId)(e, d);
  e.sourceRecordId = textField(d, "sourceRecordId");
  auto i = "input" in d && d["input"].type == Json.Type.object ? d["input"] : Json.emptyObject;
  e.input = AddressInput(textField(i, "line1"), textField(i, "line2"), textField(i, "city"), textField(i, "region"),
    textField(i, "postalCode"), textField(i, "country"));
  auto o = "output" in d && d["output"].type == Json.Type.object ? d["output"] : Json.emptyObject;
  e.output.line1 = textField(o, "line1");
  e.output.line2 = textField(o, "line2");
  e.output.city = textField(o, "city");
  e.output.region = textField(o, "region");
  e.output.postalCode = textField(o, "postalCode");
  e.output.country = textField(o, "country");
  e.output.countryRecognized = boolField(o, "countryRecognized");
  e.output.postalCodePlausible = boolField(o, "postalCodePlausible");
  e.output.quality = domainEnumOr!AddressQuality(textField(o, "quality"), AddressQuality.unverifiable);
  e.output.changes = textsField(o, "changes");
  e.cleansedAt = longField(d, "cleansedAt");
  return e;
}

// ── QualitySnapshot ─────────────────────────────────────────────────────────
Json snapshotToRecord(const QualitySnapshot e) {
  auto d = auditRecord(e);
  d["datasetId"] = e.datasetId.value;
  d["scores"] = scoresRecord(e.scores);
  d["recordCount"] = e.recordCount;
  d["violationCount"] = e.violationCount;
  d["takenAt"] = e.takenAt;
  return d;
}

QualitySnapshot recordToSnapshot(Json d) {
  QualitySnapshot e;
  readAudit!(QualitySnapshot, SnapshotId)(e, d);
  e.datasetId = DatasetId(textField(d, "datasetId"));
  e.scores = scoresField(d, "scores");
  e.recordCount = longField(d, "recordCount");
  e.violationCount = longField(d, "violationCount");
  e.takenAt = longField(d, "takenAt");
  return e;
}

// ── UserAccount ─────────────────────────────────────────────────────────────
Json userToRecord(const UserAccount e) {
  auto d = auditRecord(e);
  d["displayName"] = e.displayName;
  d["passwordHash"] = e.passwordHash;
  d["scopes"] = textsRecord(e.scopes);
  d["locked"] = e.locked;
  d["failedLogins"] = e.failedLogins;
  d["lockedUntil"] = e.lockedUntil;
  d["lastLoginAt"] = e.lastLoginAt;
  return d;
}

UserAccount recordToUser(Json d) {
  UserAccount e;
  readAudit!(UserAccount, UserAccountId)(e, d);
  e.displayName = textField(d, "displayName");
  e.passwordHash = textField(d, "passwordHash");
  e.scopes = textsField(d, "scopes");
  e.locked = boolField(d, "locked");
  e.failedLogins = cast(int) longField(d, "failedLogins");
  e.lockedUntil = longField(d, "lockedUntil");
  e.lastLoginAt = longField(d, "lastLoginAt");
  return e;
}

///
unittest {
  DataRecord r;
  r.id = RecordId("c1");
  r.tenantId = TenantId("t");
  r.datasetId = DatasetId("customers");
  r.fields = [FieldValue("b", "2"), FieldValue("a", "1")];
  r.worstSeverity = "error";
  auto back = documentToRecord(recordToDocument(r));
  auto doc = recordToDocument(r);
  assert(back.fields == r.fields, doc.toString);
  assert(back.datasetId == r.datasetId && back.worstSeverity == "error");

  MatchGroup g;
  g.id = MatchGroupId("g");
  g.candidates = [MatchCandidate(RecordId("a"), 100, MatchConfidence.exact), MatchCandidate(RecordId("b"), 91.5, MatchConfidence.high)];
  assert(recordToMatchGroup(matchGroupToRecord(g)).candidates == g.candidates);

  ValidationRule v;
  v.id = ValidationRuleId("v");
  v.ruleType = RuleType.unique;
  v.caseSensitive = false;
  v.allowedValues = ["x"];
  auto vr = recordToValidationRule(validationRuleToRecord(v));
  assert(vr.ruleType == RuleType.unique && !vr.caseSensitive && vr.allowedValues == ["x"]);
}
