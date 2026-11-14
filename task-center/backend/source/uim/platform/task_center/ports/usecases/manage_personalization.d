/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.usecases.manage_personalization;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface IManageSubstitutionRules {
  SubstitutionRule[] listSubstitutionRules(TenantId tenantId);
  SubstitutionRule getSubstitutionRule(TenantId tenantId, SubstitutionRuleId id);
  /// Users maintain their own rules; privileged callers anybody's. Auto-forward cycles are refused.
  SubstitutionRule createSubstitutionRule(CreateSubstitutionRuleRequest request);
  SubstitutionRule updateSubstitutionRule(UpdateSubstitutionRuleRequest request);
  void deleteSubstitutionRule(TenantId tenantId, SubstitutionRuleId id, UserId actor, bool privileged);
}

interface IManageUserTaskFilters {
  UserTaskFilter[] listUserTaskFilters(TenantId tenantId);
  UserTaskFilter getUserTaskFilter(TenantId tenantId, UserTaskFilterId id);
  /// isDefault = true clears the default flag of the owner's other filters.
  UserTaskFilter createUserTaskFilter(CreateUserTaskFilterRequest request);
  UserTaskFilter updateUserTaskFilter(UpdateUserTaskFilterRequest request);
  void deleteUserTaskFilter(TenantId tenantId, UserTaskFilterId id, UserId actor, bool privileged);
}
