/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.data_access_control;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct CriteriaCondition {
  string column;
  string operator;
  string[] values;
}

struct DataAccessControl {
  DataAccessControlId id;
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  CriteriaType criteriaType;
  CriteriaCondition[] conditions;
  string[] targetViewIds;
  string[] assignedUserIds;
  bool isEnabled;
  long createdAt;
  long updatedAt;
}
