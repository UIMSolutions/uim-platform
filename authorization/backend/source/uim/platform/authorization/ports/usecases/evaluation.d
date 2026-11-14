/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.ports.usecases.evaluation;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Driving port: runtime authorization checks.
interface IEvaluateAuthorization {
  /// Decide (and, if requested, log) one authorization request.
  AuthorizationResult evaluate(EvaluateAuthorizationRequest request);
  /// Active policies effectively assigned to a principal (optionally of one application).
  AuthorizationPolicy[] effectivePolicies(TenantId tenantId, string principalId, string[] groups,
    ManagedApplicationId applicationId = ManagedApplicationId.init);
}

/// Driving port: the decision log.
interface IQueryDecisions {
  DecisionRecord[] listDecisions(TenantId tenantId);
  DecisionRecord getDecision(TenantId tenantId, DecisionRecordId id);
  /// Remove decisions older than the given number of days; returns the number removed.
  size_t pruneDecisions(TenantId tenantId, int olderThanDays);
}
