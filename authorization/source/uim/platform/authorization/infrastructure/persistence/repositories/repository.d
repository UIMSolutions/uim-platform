module uim.platform.authorization.infrastructure.persistence.memory.repository;

import std.algorithm : any, filter;
import std.array : array;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class MemoryAuthorizationRepository : AuthorizationRepository {
protected:
  ManagedApplication[] applications;
  ApplicationApi[] apis;
  AuthorizationPolicy[] policies;
  PolicyAssignment[] assignments;

public:
  bool applicationNameExists(string tenantId, string name) {
    return listApplications(tenantId).any!(a => a.name == name);
  }

  void saveApplication(ManagedApplication app) { upsertApplication(app); }

  ManagedApplication findApplicationById(string tenantId, string id) {
    foreach (a; applications) if (a.tenantId == tenantId && a.id == id) return a;
    return ManagedApplication.init;
  }

  ManagedApplication[] listApplications(string tenantId) {
    return applications.filter!(a => a.tenantId == tenantId).array;
  }

  void deleteApplication(string tenantId, string id) {
    applications = applications.filter!(a => !(a.tenantId == tenantId && a.id == id)).array;
    apis = apis.filter!(a => !(a.tenantId == tenantId && a.applicationId == id)).array;
    policies = policies.filter!(p => !(p.tenantId == tenantId && p.applicationId == id)).array;
  }

  void saveApplicationApi(ApplicationApi api) { upsertApi(api); }

  ApplicationApi findApplicationApiById(string tenantId, string id) {
    foreach (a; apis) if (a.tenantId == tenantId && a.id == id) return a;
    return ApplicationApi.init;
  }

  ApplicationApi[] listApplicationApis(string tenantId) {
    return apis.filter!(a => a.tenantId == tenantId).array;
  }

  void deleteApplicationApi(string tenantId, string id) {
    apis = apis.filter!(a => !(a.tenantId == tenantId && a.id == id)).array;
  }

  void savePolicy(AuthorizationPolicy policy) { upsertPolicy(policy); }

  AuthorizationPolicy findPolicyById(string tenantId, string id) {
    foreach (p; policies) if (p.tenantId == tenantId && p.id == id) return p;
    return AuthorizationPolicy.init;
  }

  AuthorizationPolicy[] listPolicies(string tenantId) {
    return policies.filter!(p => p.tenantId == tenantId).array;
  }

  AuthorizationPolicy[] listBasePolicies(string tenantId) {
    return policies.filter!(p => p.tenantId == tenantId && p.isBasePolicy).array;
  }

  void deletePolicy(string tenantId, string id) {
    policies = policies.filter!(p => !(p.tenantId == tenantId && p.id == id)).array;
    assignments = assignments.filter!(a => !(a.tenantId == tenantId && a.policyId == id)).array;
  }

  void saveAssignment(PolicyAssignment assignment) { upsertAssignment(assignment); }

  PolicyAssignment findAssignmentById(string tenantId, string id) {
    foreach (a; assignments) if (a.tenantId == tenantId && a.id == id) return a;
    return PolicyAssignment.init;
  }

  PolicyAssignment[] listAssignments(string tenantId) {
    return assignments.filter!(a => a.tenantId == tenantId).array;
  }

  PolicyAssignment[] listAssignmentsForPrincipal(string tenantId, string principalId) {
    return assignments.filter!(a => a.tenantId == tenantId && a.principalId == principalId).array;
  }

  void deleteAssignment(string tenantId, string id) {
    assignments = assignments.filter!(a => !(a.tenantId == tenantId && a.id == id)).array;
  }

protected:
  void upsertApplication(ManagedApplication app) {
    foreach (i, current; applications) {
      if (current.tenantId == app.tenantId && current.id == app.id) {
        applications[i] = app;
        return;
      }
    }
    applications ~= app;
  }

  void upsertApi(ApplicationApi api) {
    foreach (i, current; apis) {
      if (current.tenantId == api.tenantId && current.id == api.id) {
        apis[i] = api;
        return;
      }
    }
    apis ~= api;
  }

  void upsertPolicy(AuthorizationPolicy policy) {
    foreach (i, current; policies) {
      if (current.tenantId == policy.tenantId && current.id == policy.id) {
        policies[i] = policy;
        return;
      }
    }
    policies ~= policy;
  }

  void upsertAssignment(PolicyAssignment assignment) {
    foreach (i, current; assignments) {
      if (current.tenantId == assignment.tenantId && current.id == assignment.id) {
        assignments[i] = assignment;
        return;
      }
    }
    assignments ~= assignment;
  }
}
