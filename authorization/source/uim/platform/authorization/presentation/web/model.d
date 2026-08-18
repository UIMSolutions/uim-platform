module uim.platform.authorization.presentation.web.model;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationWebModel {
  protected ManageApplicationsUseCase apps;
  private ManagePoliciesUseCase policies;
  private ManageAssignmentsUseCase assignments;
  private EvaluateAuthorizationsUseCase evaluator;

  this(ManageApplicationsUseCase apps, ManagePoliciesUseCase policies, ManageAssignmentsUseCase assignments, EvaluateAuthorizationsUseCase evaluator) {
    this.apps = apps;
    this.policies = policies;
    this.assignments = assignments;
    this.evaluator = evaluator;
  }

  ManagedApplication[] listApplications(string tenantId) { return apps.listApplications(tenantId); }
  ApplicationApi[] listApis(string tenantId) { return apps.listApplicationApis(tenantId); }
  AuthorizationPolicy[] listPolicies(string tenantId) { return policies.listPolicies(tenantId); }
  AuthorizationPolicy[] listBasePolicies(string tenantId) { return policies.listBasePolicies(tenantId); }
  PolicyAssignment[] listAssignments(string tenantId) { return assignments.listAssignments(tenantId); }
  AuthorizationDecision evaluate(EvaluateAuthorizationRequest req) { return evaluator.evaluate(req); }

  ManageApplicationsUseCase appsUseCase() { return apps; }
  ManagePoliciesUseCase policiesUseCase() { return policies; }
  ManageAssignmentsUseCase assignmentsUseCase() { return assignments; }
}
