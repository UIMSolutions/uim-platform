/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Result models of the use cases.
module uim.platform.authorization.application.dtos.results;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// The answer of an authorization check.
struct AuthorizationResult {
  bool allowed;
  string reason;
  string principalId;
  ManagedApplicationId applicationId;
  string resource;
  string action;
  string[] matchedPolicyIds;
  string[] matchedPolicyNames;
  size_t candidatePolicies;
  DecisionRecordId decisionId; /// empty if the decision was not recorded
  long evaluatedAt;
}

/// Figures of one tenant.
struct AuthorizationStatistics {
  string tenantId;
  size_t applications;
  size_t applicationApis;
  size_t policies;
  size_t basePolicies;
  size_t customPolicies;
  size_t disabledPolicies;
  size_t unassignedPolicies;
  size_t assignments;
  size_t userAssignments;
  size_t groupAssignments;
  size_t expiredAssignments;
  size_t principals;
  size_t decisions;
  size_t permittedDecisions;
  size_t deniedDecisions;
  long lastDecisionAt;
}

/// What the demo seeding created.
struct DemoDataResult {
  size_t applications;
  size_t apis;
  size_t policies;
  size_t assignments;
  size_t decisions;
}
