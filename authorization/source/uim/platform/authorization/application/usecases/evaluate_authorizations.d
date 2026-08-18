module uim.platform.authorization.application.usecases.evaluate_authorizations;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class EvaluateAuthorizationsUseCase {
  protected IAuthorizationRepository repo;
  private PolicyEvaluator evaluator;

  this(IAuthorizationRepository repo, PolicyEvaluator evaluator) {
    this.repo = repo;
    this.evaluator = evaluator;
  }

  AuthorizationDecision evaluate(EvaluateAuthorizationRequest req) {
    AuthorizationDecision result;
    result.tenantId = req.tenantId;
    result.principalId = req.principalId;
    result.applicationId = req.applicationId;
    result.resource = req.resource;
    result.action = req.action;

    auto assignments = repo.listAssignmentsForPrincipal(req.tenantId, req.principalId);
    AuthorizationPolicy[] candidates;
    foreach (a; assignments) {
      auto p = repo.findPolicyById(req.tenantId, a.policyId);
      if (!p.id.isEmpty) {
        candidates ~= p;
      }
    }

    foreach (p; candidates) {
      if (p.applicationId != req.applicationId) continue;
      if (!evaluator.resourceMatches(p.resource, req.resource)) continue;
      if (!evaluator.actionMatches(p.action, req.action)) continue;
      if (!evaluator.conditionsMatch(p.conditions, req.attributes)) continue;

      result.allowed = true;
      result.matchedPolicyIds ~= p.id;
    }

    if (result.allowed) {
      result.reason = "Access granted by at least one policy";
    } else {
      result.reason = "No policy assignment grants the requested operation";
    }

    return result;
  }
}
