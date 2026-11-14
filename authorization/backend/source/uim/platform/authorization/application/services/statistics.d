/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Figures of a tenant, computed from the repositories.
module uim.platform.authorization.application.services.statistics;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class StatisticsService : IAuthorizationStatistics {
  protected IApplicationRepository applications;
  protected IApplicationApiRepository apis;
  protected IPolicyRepository policies;
  protected IAssignmentRepository assignments;
  protected IDecisionRepository decisions;

  this(IApplicationRepository applications, IApplicationApiRepository apis, IPolicyRepository policies,
    IAssignmentRepository assignments, IDecisionRepository decisions) {
    this.applications = applications;
    this.apis = apis;
    this.policies = policies;
    this.assignments = assignments;
    this.decisions = decisions;
  }

  AuthorizationStatistics compute(TenantId tenantId) {
    AuthorizationStatistics s;
    s.tenantId = tenantId.value;
    s.applications = applications.countAll(tenantId);
    s.applicationApis = apis.countAll(tenantId);

    auto allAssignments = assignments.findAll(tenantId);
    bool[string] assigned;
    bool[string] principals;
    auto now = nowStdTime();
    foreach (a; allAssignments) {
      assigned[a.policyId.value] = true;
      principals[cast(string) a.principalType ~ ":" ~ a.principalId] = true;
      if (a.principalType == PrincipalType.user)
        s.userAssignments++;
      else
        s.groupAssignments++;
      if (a.isExpired(now))
        s.expiredAssignments++;
    }
    s.assignments = allAssignments.length;
    s.principals = principals.length;

    foreach (p; policies.findAll(tenantId)) {
      s.policies++;
      if (p.isBase)
        s.basePolicies++;
      else
        s.customPolicies++;
      if (!p.isActive)
        s.disabledPolicies++;
      if ((p.id.value in assigned) is null)
        s.unassignedPolicies++;
    }

    foreach (d; decisions.findAll(tenantId)) {
      s.decisions++;
      if (d.allowed)
        s.permittedDecisions++;
      else
        s.deniedDecisions++;
      s.lastDecisionAt = max(s.lastDecisionAt, d.createdAt);
    }
    return s;
  }
}
