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

  Json toJson() const {
    return Json([
      "column": column,
      "operator": operator,
      "values": values
    ]);
  }
}

struct DataAccessControl {
  mixin TenantEntity!(DataAccessControlId);

  SpaceId spaceId;
  string name;
  string description;
  CriteriaType criteriaType;
  CriteriaCondition[] conditions;
  ViewId[] targetViewIds;
  UserId[] assignedUserIds;
  bool isEnabled;

  Json toJson() const {
    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("criteriaType", criteriaType.to!string)
      .set("conditions", conditions.map!(c => c.toJson()).array)
      .set("targetViewIds", targetViewIds)
      .set("assignedUserIds", assignedUserIds)
      .set("isEnabled", isEnabled);
  }
}
