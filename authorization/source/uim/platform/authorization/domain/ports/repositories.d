module uim.platform.authorization.domain.ports.repositories;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

interface IAuthorizationRepository {
  bool applicationNameExists(string tenantId, string name);
  void saveApplication(ManagedApplication app);
  ManagedApplication findApplicationById(string tenantId, string id);
  ManagedApplication[] listApplications(string tenantId);
  void deleteApplication(string tenantId, string id);

  void saveApplicationApi(ApplicationApi api);
  ApplicationApi findApplicationApiById(string tenantId, string id);
  ApplicationApi[] listApplicationApis(string tenantId);
  void deleteApplicationApi(string tenantId, string id);

  void savePolicy(AuthorizationPolicy policy);
  AuthorizationPolicy findPolicyById(string tenantId, string id);
  AuthorizationPolicy[] listPolicies(string tenantId);
  AuthorizationPolicy[] listBasePolicies(string tenantId);
  void deletePolicy(string tenantId, string id);

  void saveAssignment(PolicyAssignment assignment);
  PolicyAssignment findAssignmentById(string tenantId, string id);
  PolicyAssignment[] listAssignments(string tenantId);
  PolicyAssignment[] listAssignmentsForPrincipal(string tenantId, string principalId);
  void deleteAssignment(string tenantId, string id);
}
