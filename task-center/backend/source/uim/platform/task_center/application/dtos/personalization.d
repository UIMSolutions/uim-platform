/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dtos.personalization;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct CreateSubstitutionRuleRequest {
  TenantId tenantId;
  UserId actor;
  bool privileged; /// may maintain rules of other users
  string id;

  string userId; /// "" = actor
  string substituteId;
  string definitionId;
  string status; /// active | inactive ("" = active)
  string startDate;
  string endDate;
  bool isAutoForward;
}

struct UpdateSubstitutionRuleRequest {
  TenantId tenantId;
  UserId actor;
  bool privileged;
  SubstitutionRuleId id;

  Patch!string substituteId;
  Patch!string definitionId;
  Patch!string status;
  Patch!string startDate;
  Patch!string endDate;
  Patch!bool isAutoForward;
}

struct CreateUserTaskFilterRequest {
  TenantId tenantId;
  UserId actor;
  bool privileged;
  string id;

  string userId; /// "" = actor
  string name;
  string description;
  string criteria; /// "status=open,priority=high"
  bool isDefault;
}

struct UpdateUserTaskFilterRequest {
  TenantId tenantId;
  UserId actor;
  bool privileged;
  UserTaskFilterId id;

  Patch!string name;
  Patch!string description;
  Patch!string criteria;
  Patch!bool isDefault;
}
