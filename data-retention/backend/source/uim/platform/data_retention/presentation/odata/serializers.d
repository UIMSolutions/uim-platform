/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model).
module uim.platform.data_retention.presentation.odata.serializers;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// ISO 8601 date-time (seconds, UTC) or null for 0.
Json isoTime(long stdTime) {
  auto text = isoTimeText(stdTime);
  return text.length > 0 ? Json(text) : Json(null);
}

/// ISO 8601 date or null for 0.
Json isoDate(long stdTime) {
  auto text = isoDateText(stdTime);
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
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

Json applicationGroupRow(const ApplicationGroup g, long purposes = 0, long subjects = 0) {
  auto j = auditRow(g);
  j["name"] = g.name;
  j["description"] = g.description;
  j["scope"] = cast(string) g.scope_;
  j["applicationIds"] = texts(g.applicationIds);
  j["applicationsText"] = g.applicationIds.join(", ");
  j["active"] = g.active;
  j["businessPurposeCount"] = purposes;
  j["dataSubjectCount"] = subjects;
  return j;
}

Json legalEntityRow(const LegalEntity e) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["country"] = e.country;
  j["region"] = e.region;
  j["active"] = e.active;
  return j;
}

Json dataSubjectRoleRow(const DataSubjectRole r) {
  auto j = auditRow(r);
  j["name"] = r.name;
  j["description"] = r.description;
  j["active"] = r.active;
  return j;
}

/// Derived attributes of a business purpose row.
struct PurposeFacts {
  long legalGrounds;
  long completeLegalGrounds;
  long dataSubjects;
  string rulesText; /// "Contract performance: 1 year + 3 years; …"
}

Json businessPurposeRow(const BusinessPurpose p, PurposeFacts f = PurposeFacts.init) {
  auto j = auditRow(p);
  j["name"] = p.name;
  j["description"] = p.description;
  j["applicationGroupId"] = p.applicationGroupId.value;
  j["dataSubjectRoleId"] = p.dataSubjectRoleId.value;
  j["legalEntityId"] = textOrNull(p.legalEntityId.value);
  j["status"] = cast(string) p.status;
  j["activatedAt"] = isoTime(p.activatedAt);
  j["legalGroundCount"] = f.legalGrounds;
  j["completeLegalGrounds"] = f.completeLegalGrounds;
  j["dataSubjectCount"] = f.dataSubjects;
  j["rulesText"] = f.rulesText;
  return j;
}

Json legalGroundRow(const LegalGround g, const ResidenceRule residence = ResidenceRule.init,
  const RetentionRule retention = RetentionRule.init) {
  auto j = auditRow(g);
  j["businessPurposeId"] = g.businessPurposeId.value;
  j["name"] = g.name;
  j["description"] = g.description;
  j["type"] = cast(string) g.type;
  j["legalReference"] = g.legalReference;
  j["active"] = g.active;
  j["residenceRuleId"] = textOrNull(residence.id.value);
  j["residence"] = residence.isNull ? Json(null) : Json(residence.period.text ~ (residence.active ? "" : " (inactive)"));
  j["retentionRuleId"] = textOrNull(retention.id.value);
  j["retention"] = retention.isNull ? Json(null) : Json(retention.period.text ~ (retention.active ? "" : " (inactive)"));
  j["actionOnExpiry"] = retention.isNull ? Json(null) : Json(cast(string) retention.actionOnExpiry);
  return j;
}

Json residenceRuleRow(const ResidenceRule r) {
  auto j = auditRow(r);
  j["businessPurposeId"] = r.businessPurposeId.value;
  j["legalGroundId"] = r.legalGroundId.value;
  j["duration"] = r.period.duration;
  j["periodUnit"] = cast(string) r.period.unit;
  j["periodText"] = r.period.text;
  j["active"] = r.active;
  return j;
}

Json retentionRuleRow(const RetentionRule r) {
  auto j = auditRow(r);
  j["businessPurposeId"] = r.businessPurposeId.value;
  j["legalGroundId"] = r.legalGroundId.value;
  j["duration"] = r.period.duration;
  j["periodUnit"] = cast(string) r.period.unit;
  j["periodText"] = r.period.text;
  j["actionOnExpiry"] = cast(string) r.actionOnExpiry;
  j["active"] = r.active;
  return j;
}

/// The evaluation members (shared by DataSubject rows and simulations).
void putEvaluation(ref Json j, const RetentionEvaluation e) {
  j["phase"] = cast(string) e.phase;
  j["governingLegalGroundId"] = textOrNull(e.governingLegalGroundId.value);
  j["governingLegalGroundName"] = textOrNull(e.governingLegalGroundName);
  j["residence"] = e.phase == RetentionPhase.noRule ? Json(null) : Json(e.residence.text);
  j["retention"] = e.phase == RetentionPhase.noRule ? Json(null) : Json(e.retention.text);
  j["endOfPurpose"] = isoDate(e.endOfPurpose);
  j["endOfRetention"] = isoDate(e.endOfRetention);
  j["actionOnExpiry"] = e.phase == RetentionPhase.noRule ? Json(null) : Json(cast(string) e.actionOnExpiry);
  j["retentionReason"] = e.reason;
}

Json dataSubjectRow(const DataSubject s) {
  auto j = auditRow(s);
  j["externalId"] = s.externalId;
  j["displayName"] = s.displayName;
  j["applicationGroupId"] = s.applicationGroupId.value;
  j["dataSubjectRoleId"] = textOrNull(s.dataSubjectRoleId.value);
  j["businessPurposeId"] = s.businessPurposeId.value;
  j["legalGroundId"] = textOrNull(s.legalGroundId.value);
  j["legalEntityId"] = textOrNull(s.legalEntityId.value);
  j["referenceDate"] = isoDate(s.referenceDate);
  j["lifecycleStatus"] = cast(string) s.lifecycleStatus;
  j["legalHold"] = s.legalHold;
  j["legalHoldReason"] = textOrNull(s.legalHoldReason);
  j["blockedAt"] = isoTime(s.blockedAt);
  j["archivedAt"] = isoTime(s.archivedAt);
  j["markedForDeletionAt"] = isoTime(s.markedForDeletionAt);
  j["deletedAt"] = isoTime(s.deletedAt);
  j["deletionMethod"] = textOrNull(s.deletionMethod);
  auto e = s.evaluation;
  putEvaluation(j, e);
  if (s.isDeleted) { // nothing left to evaluate
    j["phase"] = Json(null);
    j["retentionReason"] = "The personal data was destroyed (" ~ s.deletionMethod ~ ") on " ~ isoDateText(s.deletedAt);
  }
  j["daysToEndOfRetention"] = e.endOfRetention > 0 && !s.isDeleted ? Json(e.daysToEndOfRetention(e.evaluatedAt)) : Json(null);
  j["dueForBlocking"] = e.dueForBlocking(s.lifecycleStatus);
  j["dueForDestruction"] = e.dueForDestruction(s.lifecycleStatus, s.legalHold);
  return j;
}

Json deletionRequestRow(const DeletionRequest r) {
  auto j = auditRow(r);
  j["dataSubjectId"] = r.dataSubjectId.value;
  j["applicationGroupId"] = r.applicationGroupId.value;
  j["action"] = cast(string) r.action;
  j["status"] = cast(string) r.status;
  j["reason"] = r.reason;
  j["processedAt"] = isoTime(r.processedAt);
  j["resultMessage"] = textOrNull(r.resultMessage);
  j["earliestDeletion"] = isoDate(r.earliestDeletionAt);
  return j;
}

Json archivingJobRow(const ArchivingJob a) {
  auto j = auditRow(a);
  j["applicationGroupId"] = a.applicationGroupId.value;
  j["operation"] = cast(string) a.operation;
  j["dryRun"] = a.dryRun;
  j["referenceBefore"] = isoDate(a.referenceBefore);
  j["scheduledAt"] = isoTime(a.scheduledAt);
  j["status"] = cast(string) a.status;
  j["startedAt"] = isoTime(a.startedAt);
  j["completedAt"] = isoTime(a.completedAt);
  j["selected"] = a.selected;
  j["archived"] = a.archived;
  j["destroyed"] = a.destroyed;
  j["skipped"] = a.skipped;
  j["failed"] = a.failed;
  j["errorMessage"] = textOrNull(a.errorMessage);
  j["log"] = texts(a.log);
  j["logText"] = a.log.join("\n");
  return j;
}

Json userRow(const UserAccount u, long now) {
  auto j = auditRow(u);
  j["displayName"] = u.displayName;
  j["password"] = Json(null);
  j["scopes"] = texts(u.scopes);
  j["scopesText"] = u.scopes.join(", ");
  j["locked"] = u.locked;
  j["temporarilyLocked"] = !u.locked && u.isLockedAt(now);
  j["failedLogins"] = u.failedLogins;
  j["lastLoginAt"] = isoTime(u.lastLoginAt);
  return j;
}

Json statisticsRow(const DrStatistics s) @trusted {
  import std.traits : FieldNameTuple;

  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!DrStatistics) {
    static if (name == "nextEndOfRetention")
      j[name] = isoDate(s.nextEndOfRetention);
    else static if (name == "computedAt")
      j[name] = isoTime(s.computedAt);
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

Json checkResultRow(const EndOfPurposeCheckResult r) {
  auto j = Json.emptyObject;
  j["applicationGroupId"] = textOrNull(r.applicationGroupId);
  j["simulated"] = r.simulated;
  j["checked"] = r.checked;
  j["noRule"] = r.noRule;
  j["withinResidence"] = r.withinResidence;
  j["withinRetention"] = r.withinRetention;
  j["endOfRetention"] = r.endOfRetention;
  j["alreadyDeleted"] = r.alreadyDeleted;
  j["blocked"] = r.blocked;
  j["markedForDeletion"] = r.markedForDeletion;
  j["legalHolds"] = r.legalHolds;
  j["blockedSubjects"] = r.blockedSubjects.join(", ");
  j["markedSubjects"] = r.markedSubjects.join(", ");
  j["checkedAt"] = isoTime(r.checkedAt);
  return j;
}

Json simulationRow(const RetentionEvaluation e, string purpose, long referenceDate) {
  auto j = Json.emptyObject;
  j["businessPurposeId"] = purpose;
  j["referenceDate"] = isoDate(referenceDate);
  putEvaluation(j, e);
  return j;
}

Json seedRow(const SeedResult r) @trusted {
  import std.traits : FieldNameTuple;

  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!SeedResult)
    j[name] = __traits(getMember, r, name);
  return j;
}

Json runSummaryRow(const RunSummary r) {
  return Json(["started": Json(r.started), "completed": Json(r.completed), "rejected": Json(r.rejected),
      "failed": Json(r.failed)]);
}
