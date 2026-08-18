module uim.platform.authorization.presentation.cli.model;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationCliModel {
  protected ManageApplicationsUseCase apps;
  private ManagePoliciesUseCase policies;
  private ManageAssignmentsUseCase assignments;

  this(ManageApplicationsUseCase apps, ManagePoliciesUseCase policies, ManageAssignmentsUseCase assignments) {
    this.apps = apps;
    this.policies = policies;
    this.assignments = assignments;
  }

  size_t applicationCount(string tenantId) { return apps.listApplications(tenantId).length; }
  size_t policyCount(string tenantId) { return policies.listPolicies(tenantId).length; }
  size_t assignmentCount(string tenantId) { return assignments.listAssignments(tenantId).length; }
}
