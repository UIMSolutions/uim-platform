/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.ports.usecases.assignments;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Driving port: assignment of policies to users and groups.
interface IManageAssignments {
  PolicyAssignment assignPolicy(CreateAssignmentRequest request);
  PolicyAssignment updateAssignment(UpdateAssignmentRequest request);
  PolicyAssignment getAssignment(TenantId tenantId, PolicyAssignmentId id);
  PolicyAssignment[] listAssignments(TenantId tenantId);
  PolicyAssignment[] listAssignments(TenantId tenantId, PolicyId policyId);
  PolicyAssignment[] listAssignmentsOf(TenantId tenantId, PrincipalType type, string principalId);
  void revokeAssignment(TenantId tenantId, PolicyAssignmentId id);
}
