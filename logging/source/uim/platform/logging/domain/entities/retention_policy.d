/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.retention_policy;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct RetentionPolicy {
  RetentionPolicyId id;
  TenantId tenantId;
  string name;
  string description;
  DataType dataType = DataType.all;
  int retentionDays = 30;
  double maxSizeGB = 10.0;
  bool isDefault;
  bool isActive = true;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
