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
    return json.emptyObject
      .set("id", id)
      .set("tenantId", tenantId)
      .set("name", name)
      .set("description", description)
      .set("retentionDays", retentionDays)
      .set("categories", categories.map!(c => Json(c)).array.toJson)
      .set("status", status.to!string)
      .set("isDefault", isDefault)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}
