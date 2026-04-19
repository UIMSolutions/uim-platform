/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.retention_policy;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Retention policy — how long audit data is kept.
@safe:
struct RetentionPolicy {
  RetentionPolicyId id;
  TenantId tenantId;
  string name;
  string description;
  int retentionDays = 90; // SAP default is 90 days
  AuditCategory[] categories; // which categories this policy covers
  RetentionStatus status = RetentionStatus.active;
  bool isDefault;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return Json.emptyObject
      .set("id", id.toString)
      .set("tenantId", tenantId)
      .set("name", name)
      .set("description", description)
      .set("retentionDays", retentionDays)
      .set("categories", categories.map!(c => c.to!string).array.toJson)
      .set("status", status.to!string)
      .set("isDefault", isDefault)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }

  static RetentionPolicy fromJson(Json j) {
    RetentionPolicy p;
    p.id = j.getString("id");
    p.tenantId = j.getString("tenantId");
    p.name = j.getString("name");
    p.description = j.getString("description");
    p.retentionDays = j.getInteger("retentionDays");
    foreach (c; j.getArray("categories"))
      p.categories ~= toAuditCategory(c.getString);
    //
    // p.categories = j.getArray("categories").map!(c => toAuditCategory(c.getString)).array;
    p.status = RetentionStatus.fromString(j.getString("status"));
    p.isDefault = j.getBoolean("isDefault");
    p.createdAt = j.getLong("createdAt");
    p.updatedAt = j.getLong("updatedAt");
    return p;
  }
}
unittest {
  auto policy = RetentionPolicy();
  policy.id = "policy1";
  policy.tenantId = "tenant1";
  policy.name = "Default Policy";
  policy.description = "Default retention policy";
  policy.retentionDays = 90;
  // TODO: policy.categories = [AuditCategory.login, AuditCategory.dataChange];
  policy.status = RetentionStatus.active;
  policy.isDefault = true;
  policy.createdAt = Clock.currStdTime();
  policy.updatedAt = Clock.currStdTime();

  auto json = policy.toJson();
  assert(json.getString("id") == "policy1");
  assert(json.getString("tenantId") == "tenant1");
  assert(json.getString("name") == "Default Policy");
  assert(json.getString("description") == "Default retention policy");
  assert(json.getInteger("retentionDays") == 90);
  // TODO: assert(json.getArray("categories").length == 2);
  assert(json.getString("status") == "active");
  assert(json.getBoolean("isDefault") == true);
}

