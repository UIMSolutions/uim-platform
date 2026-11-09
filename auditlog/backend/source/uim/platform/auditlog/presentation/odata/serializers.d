/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Conversion between domain entities / DTOs and OData v4 JSON payloads.
module uim.platform.auditlog.presentation.odata.serializers;

import core.time : Duration;
import std.datetime.systime : SysTime;
import std.datetime.timezone : UTC;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// stdTime (hnsecs) → Edm.DateTimeOffset ("2026-11-09T10:00:00Z"); 0 → null.
Json odataTime(long stdTime) {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime, UTC());
  t.fracSecs = Duration.zero;
  return Json(t.toISOExtString);
}

/// Edm.DateTimeOffset → stdTime; "" / null → 0. Throws on invalid values.
long parseODataTime(Json value) {
  if (value.type != Json.Type.string || value.get!string.length == 0)
    return 0;
  return SysTime.fromISOExtString(value.get!string).stdTime;
}

private void base(T)(ref Json j, const ref T e) {
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdBy"] = e.createdBy.value;
  j["createdAt"] = odataTime(e.createdAt);
  j["updatedBy"] = e.updatedBy.value;
  j["updatedAt"] = odataTime(e.updatedAt);
}

private Json attrs(const AuditAttribute[] attributes) {
  auto arr = Json.emptyArray;
  foreach (a; attributes) {
    auto j = Json.emptyObject;
    j["name"] = a.name;
    j["oldValue"] = a.oldValue;
    j["newValue"] = a.newValue;
    arr ~= j;
  }
  return arr;
}

private Json cats(const AuditCategory[] categories) {
  auto arr = Json.emptyArray;
  foreach (c; categories)
    arr ~= Json(c.to!string);
  return arr;
}

Json toOData(const AuditLogEntry e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["timestamp"] = odataTime(e.timestamp);
  j["category"] = e.category.to!string;
  j["severity"] = e.severity.to!string;
  j["action"] = cast(string) e.action;
  j["outcome"] = e.outcome.to!string;
  j["userId"] = e.userId.value;
  j["userName"] = e.userName;
  j["serviceId"] = e.serviceId.value;
  j["serviceName"] = e.serviceName;
  j["objectType"] = e.objectType;
  j["objectId"] = e.objectId;
  j["message"] = e.message;
  j["attributes"] = attrs(e.attributes);
  j["ipAddress"] = e.ipAddress;
  j["userAgent"] = e.userAgent;
  j["correlationId"] = e.correlationId;
  j["originApp"] = e.originApp;
  j["formatVersion"] = e.formatVersion;
  return j;
}

Json toOData(const SecurityEvent e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["timestamp"] = odataTime(e.timestamp);
  j["auditLogId"] = e.auditLogId.value;
  j["userId"] = e.userId.value;
  j["userName"] = e.userName;
  j["eventType"] = e.eventType;
  j["ipAddress"] = e.ipAddress;
  j["userAgent"] = e.userAgent;
  j["clientId"] = e.clientId;
  j["identityProvider"] = e.identityProvider;
  j["authMethod"] = e.authMethod;
  j["outcome"] = e.outcome.to!string;
  j["failureReason"] = e.failureReason;
  j["riskLevel"] = e.riskLevel;
  return j;
}

Json toOData(const DataAccessLog e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["timestamp"] = odataTime(e.timestamp);
  j["auditLogId"] = e.auditLogId.value;
  j["accessedBy"] = e.accessedBy.value;
  j["dataSubject"] = e.dataSubject;
  j["dataObjectType"] = e.dataObjectType;
  j["dataObjectId"] = e.dataObjectId;
  j["accessedFields"] = stringsToJson(e.accessedFields);
  j["purpose"] = e.purpose;
  j["channel"] = e.channel;
  return j;
}

Json toOData(const ConfigChangeLog e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["timestamp"] = odataTime(e.timestamp);
  j["auditLogId"] = e.auditLogId.value;
  j["changedBy"] = e.changedBy.value;
  j["configType"] = e.configType;
  j["configObjectId"] = e.configObjectId;
  j["changes"] = attrs(e.changes);
  j["reason"] = e.reason;
  return j;
}

Json toOData(const RetentionPolicy e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["retentionDays"] = e.retentionDays;
  j["categories"] = cats(e.categories);
  j["status"] = e.status.to!string;
  j["isDefault"] = e.isDefault;
  return j;
}

Json toOData(const AuditConfig e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["status"] = e.status.to!string;
  j["logDataAccess"] = e.logDataAccess;
  j["logDataModification"] = e.logDataModification;
  j["logSecurityEvents"] = e.logSecurityEvents;
  j["logConfigurationChanges"] = e.logConfigurationChanges;
  j["enableDataMasking"] = e.enableDataMasking;
  j["maskedFields"] = stringsToJson(e.maskedFields);
  j["excludedServices"] = stringsToJson(e.excludedServices);
  j["minimumSeverity"] = e.minimumSeverity.to!string;
  j["rateLimitPerSecond"] = e.rateLimitPerSecond;
  return j;
}

Json toOData(const ExportJob e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["requestedBy"] = e.requestedBy.value;
  j["format"] = e.format_.to!string;
  j["status"] = e.status.to!string;
  j["categories"] = cats(e.categories);
  j["timeFrom"] = odataTime(e.timeFrom);
  j["timeTo"] = odataTime(e.timeTo);
  j["downloadUrl"] = e.downloadUrl;
  j["totalRecords"] = cast(int) e.totalRecords;
  j["completedAt"] = odataTime(e.completedAt);
  j["errorMessage"] = e.errorMessage;
  return j;
}

Json toOData(const AuditStatistics s) {
  size_t get(const size_t[string] map, string key) {
    if (auto v = key in map)
      return *v;
    return 0;
  }

  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId.value;
  j["totalEntries"] = cast(int) s.totalEntries;
  j["securityEvents"] = cast(int) s.securityEvents;
  j["failedLogins"] = cast(int) s.failedLogins;
  j["dataAccessLogs"] = cast(int) s.dataAccessLogs;
  j["configChanges"] = cast(int) s.configChanges;
  j["retentionPolicies"] = cast(int) s.retentionPolicies;
  j["exportJobs"] = cast(int) s.exportJobs;
  j["retentionDays"] = s.retentionDays;
  j["lastEntryAt"] = odataTime(s.lastEntryAt);
  j["categorySecurityEvents"] = cast(int) get(s.byCategory, "securityEvents");
  j["categoryConfiguration"] = cast(int) get(s.byCategory, "configuration");
  j["categoryDataAccess"] = cast(int) get(s.byCategory, "dataAccess");
  j["categoryDataModification"] = cast(int) get(s.byCategory, "dataModification");
  j["severityInfo"] = cast(int) get(s.bySeverity, "info");
  j["severityWarning"] = cast(int) get(s.bySeverity, "warning");
  j["severityError"] = cast(int) get(s.bySeverity, "error");
  j["severityCritical"] = cast(int) get(s.bySeverity, "critical");
  return j;
}

// ── Payload → request DTOs ──────────────────────────────────────────────────

private AuditAttribute[] attributesOf(Json body, string key) {
  return attributesFromJson(body, key);
}

private E enumOf(E)(Json body, string key, E defaultValue) {
  return fieldEnum!E(body, key, defaultValue);
}

/// Parse the categories of a payload. Accepts enum names and "audit.*" names.
AuditCategory[] categoriesOf(Json body, string key) {
  return fieldStrings(body, key).map!(s => s.toAuditCategory).array;
}

WriteAuditLogRequest toWriteAuditLogRequest(Json body, TenantId tenantId) {
  WriteAuditLogRequest r;
  r.tenantId = tenantId;
  r.userId = UserId(body.fieldString("userId"));
  r.userName = body.fieldString("userName");
  r.serviceId = ServiceId(body.fieldString("serviceId"));
  r.serviceName = body.fieldString("serviceName");
  r.category = body.fieldString("category", "securityEvents").toAuditCategory;
  r.severity = enumOf!AuditSeverity(body, "severity", AuditSeverity.info);
  r.action = body.fieldString("action", "create").toAuditAction;
  r.outcome = enumOf!AuditOutcome(body, "outcome", AuditOutcome.success);
  r.objectType = body.fieldString("objectType");
  r.objectId = body.fieldString("objectId");
  r.message = body.fieldString("message");
  r.attributes = attributesOf(body, "attributes");
  r.ipAddress = body.fieldString("ipAddress");
  r.userAgent = body.fieldString("userAgent");
  r.correlationId = body.fieldString("correlationId");
  r.originApp = body.fieldString("originApp");
  return r;
}

WriteSecurityEventRequest toWriteSecurityEventRequest(Json body, TenantId tenantId) {
  WriteSecurityEventRequest r;
  r.tenantId = tenantId;
  r.userId = UserId(body.fieldString("userId"));
  r.userName = body.fieldString("userName");
  r.eventType = body.fieldString("eventType");
  r.ipAddress = body.fieldString("ipAddress");
  r.userAgent = body.fieldString("userAgent");
  r.clientId = body.fieldString("clientId");
  r.identityProvider = body.fieldString("identityProvider");
  r.authMethod = body.fieldString("authMethod");
  r.outcome = enumOf!AuditOutcome(body, "outcome", AuditOutcome.success);
  r.failureReason = body.fieldString("failureReason");
  r.riskLevel = body.fieldString("riskLevel");
  return r;
}

WriteDataAccessLogRequest toWriteDataAccessLogRequest(Json body, TenantId tenantId) {
  WriteDataAccessLogRequest r;
  r.tenantId = tenantId;
  r.accessedBy = UserId(body.fieldString("accessedBy"));
  r.dataSubject = body.fieldString("dataSubject");
  r.dataObjectType = body.fieldString("dataObjectType");
  r.dataObjectId = body.fieldString("dataObjectId");
  r.accessedFields = body.fieldStrings("accessedFields");
  r.purpose = body.fieldString("purpose");
  r.channel = body.fieldString("channel");
  return r;
}

WriteConfigChangeLogRequest toWriteConfigChangeRequest(Json body, TenantId tenantId) {
  WriteConfigChangeLogRequest r;
  r.tenantId = tenantId;
  r.changedBy = UserId(body.fieldString("changedBy"));
  r.configType = body.fieldString("configType");
  r.configObjectId = body.fieldString("configObjectId");
  r.changes = attributesOf(body, "changes");
  r.reason = body.fieldString("reason");
  return r;
}

CreateRetentionPolicyRequest toCreateRetentionPolicyRequest(Json body, TenantId tenantId) {
  CreateRetentionPolicyRequest r;
  r.tenantId = tenantId;
  r.name = body.fieldString("name");
  r.description = body.fieldString("description");
  r.retentionDays = body.fieldInt("retentionDays", 90);
  r.categories = categoriesOf(body, "categories");
  r.isDefault = body.fieldBool("isDefault");
  return r;
}

/// PATCH semantics: properties missing in the body keep their current value.
UpdateRetentionPolicyRequest toUpdateRetentionPolicyRequest(Json body, const RetentionPolicy current) {
  UpdateRetentionPolicyRequest r;
  r.tenantId = current.tenantId;
  r.retentionPolicyId = current.id;
  r.name = body.fieldString("name", current.name);
  r.description = body.fieldString("description", current.description);
  r.retentionDays = body.fieldInt("retentionDays", current.retentionDays);
  r.categories = "categories" in body ? categoriesOf(body, "categories") : current.categories.dup;
  r.status = enumOf!RetentionStatus(body, "status", current.status);
  return r;
}

CreateAuditConfigRequest toCreateAuditConfigRequest(Json body, TenantId tenantId) {
  CreateAuditConfigRequest r;
  r.tenantId = tenantId;
  r.name = body.fieldString("name");
  r.logDataAccess = body.fieldBool("logDataAccess", true);
  r.logDataModification = body.fieldBool("logDataModification", true);
  r.logSecurityEvents = body.fieldBool("logSecurityEvents", true);
  r.logConfigurationChanges = body.fieldBool("logConfigurationChanges", true);
  r.enableDataMasking = body.fieldBool("enableDataMasking");
  r.maskedFields = body.fieldStrings("maskedFields");
  r.excludedServices = body.fieldStrings("excludedServices");
  r.minimumSeverity = enumOf!AuditSeverity(body, "minimumSeverity", AuditSeverity.info);
  r.rateLimitPerSecond = body.fieldInt("rateLimitPerSecond", 8);
  return r;
}

/// PATCH semantics: properties missing in the body keep their current value.
UpdateAuditConfigRequest toUpdateAuditConfigRequest(Json body, const AuditConfig current) {
  UpdateAuditConfigRequest r;
  r.id = current.id;
  r.tenantId = current.tenantId;
  r.name = body.fieldString("name", current.name);
  r.status = enumOf!ConfigStatus(body, "status", current.status);
  r.logDataAccess = body.fieldBool("logDataAccess", current.logDataAccess);
  r.logDataModification = body.fieldBool("logDataModification", current.logDataModification);
  r.logSecurityEvents = body.fieldBool("logSecurityEvents", current.logSecurityEvents);
  r.logConfigurationChanges = body.fieldBool("logConfigurationChanges", current.logConfigurationChanges);
  r.enableDataMasking = body.fieldBool("enableDataMasking", current.enableDataMasking);
  r.maskedFields = "maskedFields" in body ? body.fieldStrings("maskedFields") : current.maskedFields.dup;
  r.excludedServices = "excludedServices" in body ? body.fieldStrings("excludedServices") : current.excludedServices.dup;
  r.minimumSeverity = enumOf!AuditSeverity(body, "minimumSeverity", current.minimumSeverity);
  r.rateLimitPerSecond = body.fieldInt("rateLimitPerSecond", current.rateLimitPerSecond);
  return r;
}

CreateExportJobRequest toCreateExportJobRequest(Json body, TenantId tenantId, UserId caller) {
  CreateExportJobRequest r;
  r.tenantId = tenantId;
  auto requestedBy = body.fieldString("requestedBy");
  r.requestedBy = requestedBy.length > 0 ? UserId(requestedBy) : caller;
  r.format_ = enumOf!ExportFormat(body, "format", ExportFormat.json);
  r.categories = categoriesOf(body, "categories");
  r.timeFrom = parseODataTime("timeFrom" in body ? body["timeFrom"] : Json(null));
  r.timeTo = parseODataTime("timeTo" in body ? body["timeTo"] : Json(null));
  return r;
}

///
unittest {
  mixin(ShowTest!("OData serializers"));

  assert(odataTime(0).type == Json.Type.null_);
  auto t = odataTime(SysTime.fromISOExtString("2026-11-09T10:11:12.345Z").stdTime);
  assert(t.get!string == "2026-11-09T10:11:12Z");
  assert(parseODataTime(Json("2026-11-09T10:11:12Z")) > 0);

  auto e = AuditLogEntry(TenantId("t1"));
  e.action = AuditAction.delete_;
  assert(toOData(e)["action"].get!string == "delete");

  auto body = parseJsonString(`{"message": "m", "category": "dataAccess", "severity": "error", "action": "read"}`);
  auto req = toWriteAuditLogRequest(body, TenantId("t1"));
  assert(req.category == AuditCategory.dataAccess);
  assert(req.severity == AuditSeverity.error);
  assert(req.action == AuditAction.read_);

  RetentionPolicy current;
  current.name = "old";
  current.retentionDays = 30;
  auto upd = toUpdateRetentionPolicyRequest(parseJsonString(`{"retentionDays": 60}`), current);
  assert(upd.name == "old" && upd.retentionDays == 60);
}
