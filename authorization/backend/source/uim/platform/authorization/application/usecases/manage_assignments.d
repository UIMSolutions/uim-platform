/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.application.usecases.manage_assignments;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Use case: assign policies to users and groups.
///
/// Rules: a principal gets a policy at most once · disabled policies cannot be
/// assigned · validTo must be after validFrom.
class ManageAssignmentsUseCase : IManageAssignments {
  protected IAssignmentRepository assignments;
  protected IPolicyRepository policies;

  this(IAssignmentRepository assignments, IPolicyRepository policies) {
    this.assignments = assignments;
    this.policies = policies;
  }

  PolicyAssignment assignPolicy(CreateAssignmentRequest r) {
    PolicyAssignment a;
    a.policyId = r.policyId;
    a.principalType = parseDomainEnumOr!PrincipalType(r.principalType, PrincipalType.user, "principalType");
    a.principalId = r.principalId.strip;
    a.validFrom = r.validFrom;
    a.validTo = r.validTo;
    a.validate();

    auto policy = required(policies.findById(r.tenantId, a.policyId), "Policy '" ~ a.policyId.value ~ "'");
    if (!policy.isActive)
      throw AuthorizationException.ruleViolation("Policy '" ~ policy.name ~ "' is disabled and cannot be assigned");
    foreach (existing; assignments.findByPolicy(r.tenantId, a.policyId))
      if (existing.principalType == a.principalType && existing.principalId == a.principalId)
        throw AuthorizationException.conflict("Policy '" ~ policy.name ~ "' is already assigned to "
            ~ cast(string) a.principalType ~ " '" ~ a.principalId ~ "'");

    stampCreated(a, r.tenantId, r.actor);
    assignments.save(a);
    return a;
  }

  PolicyAssignment updateAssignment(UpdateAssignmentRequest r) {
    auto a = getAssignment(r.tenantId, r.id);
    if (r.fields.has("validFrom"))
      a.validFrom = r.validFrom;
    if (r.fields.has("validTo"))
      a.validTo = r.validTo;
    a.validate();
    stampUpdated(a, r.actor);
    assignments.save(a);
    return a;
  }

  PolicyAssignment getAssignment(TenantId tenantId, PolicyAssignmentId id) {
    return required(assignments.findById(tenantId, id), "Assignment '" ~ id.value ~ "'");
  }

  PolicyAssignment[] listAssignments(TenantId tenantId) {
    return assignments.findAll(tenantId);
  }

  PolicyAssignment[] listAssignments(TenantId tenantId, PolicyId policyId) {
    return assignments.findByPolicy(tenantId, policyId);
  }

  PolicyAssignment[] listAssignmentsOf(TenantId tenantId, PrincipalType type, string principalId) {
    return assignments.findByPrincipal(tenantId, type, principalId);
  }

  void revokeAssignment(TenantId tenantId, PolicyAssignmentId id) {
    getAssignment(tenantId, id);
    assignments.removeById(tenantId, id);
  }
}
