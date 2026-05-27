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
  mixin TenantEntity!(RetentionPolicyId);
  string name;
  string description;
  int retentionDays = 90; // SAP default is 90 days
  AuditCategory[] categories; // which categories this policy covers
  RetentionStatus status = RetentionStatus.active;
  bool isDefault;

  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("retentionDays", retentionDays)
      .set("categories", categories.map!(c => c.to!string).array.toJson)
      .set("status", status.to!string)
      .set("isDefault", isDefault);
  }

  static RetentionPolicy fromJson(Json j) {
    RetentionPolicy p;
    p.id = RetentionPolicyId(precheck.id);
    p.tenantId = TenantId(data.getString("tenantId"));
    p.name = data.getString("name");
    p.description = data.getString("description");
    p.retentionDays = j.getInteger("retentionDays");
    foreach (c; j.getArray("categories"))
      p.categories ~= toAuditCategory(c.getString);
    //
    // p.categories = j.getArray("categories").map!(c => toAuditCategory(c.getString)).array.toJson;
    p.status = data.getString("status").to!RetentionStatus;
    p.isDefault = j.getBoolean("isDefault");
    p.createdAt = j.getLong("createdAt");
    p.updatedAt = j.getLong("updatedAt");
    return p;
  }
}


