/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports: persistence of the authorization business objects.
module uim.platform.authorization.ports.repositories.authorization;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

interface IApplicationRepository : IEntityRepository!(ManagedApplication, ManagedApplicationId) {
  ManagedApplication findByName(TenantId tenantId, string name);
}

interface IApplicationApiRepository : IEntityRepository!(ApplicationApi, ApplicationApiId) {
  ApplicationApi[] findByApplication(TenantId tenantId, ManagedApplicationId applicationId);
  ApplicationApi findByName(TenantId tenantId, ManagedApplicationId applicationId, string name);
}

interface IPolicyRepository : IEntityRepository!(AuthorizationPolicy, PolicyId) {
  AuthorizationPolicy[] findByApplication(TenantId tenantId, ManagedApplicationId applicationId);
  AuthorizationPolicy findByName(TenantId tenantId, ManagedApplicationId applicationId, string name);
}

interface IAssignmentRepository : IEntityRepository!(PolicyAssignment, PolicyAssignmentId) {
  PolicyAssignment[] findByPolicy(TenantId tenantId, PolicyId policyId);
  PolicyAssignment[] findByPrincipal(TenantId tenantId, PrincipalType type, string principalId);
}

interface IDecisionRepository : IEntityRepository!(DecisionRecord, DecisionRecordId) {
  /// Remove records created before the given std time; returns the number removed.
  size_t removeOlderThan(TenantId tenantId, long stdTime);
}
