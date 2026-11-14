/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.usecases.access_rules;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Maintain the access control rules of a Cloud Connector and evaluate requests.
interface IManageAccessRulesUseCase : IManageResource!(AccessRule, AccessRuleId,
    CreateAccessRuleRequest, UpdateAccessRuleRequest) {
  UsecaseResult enable(TenantId tenantId, AccessRuleId id, UserId actor);
  UsecaseResult disable(TenantId tenantId, AccessRuleId id, UserId actor);
  /// Would the connector let this request through? (dry run, logged)
  AccessCheckResult checkAccess(AccessCheckRequest request);
}
