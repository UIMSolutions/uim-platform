/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.application.usecases.evaluate_authorization;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Use case: runtime authorization check (AMS "authorization decision").
/// The decision itself is made by the pure domain service PolicyEvaluator;
/// this interactor loads the data, records the decision and publishes it.
class EvaluateAuthorizationUseCase : IEvaluateAuthorization {
  protected IManageApplications applications;
  protected IPolicyRepository policies;
  protected IAssignmentRepository assignments;
  protected IDecisionRepository decisions;
  protected IDecisionPublisher publisher;
  protected PolicyEvaluator evaluator;
  protected bool recordDecisions;

  this(IManageApplications applications, IPolicyRepository policies, IAssignmentRepository assignments,
    IDecisionRepository decisions, IDecisionPublisher publisher, PolicyEvaluator evaluator, bool recordDecisions = true) {
    this.applications = applications;
    this.policies = policies;
    this.assignments = assignments;
    this.decisions = decisions;
    this.publisher = publisher;
    this.evaluator = evaluator;
    this.recordDecisions = recordDecisions;
  }

  AuthorizationResult evaluate(EvaluateAuthorizationRequest r) {
    if (r.principalId.strip.length == 0)
      throw AuthorizationException.invalid("principalId is required");
    if (r.resource.strip.length == 0 || r.action.strip.length == 0)
      throw AuthorizationException.invalid("resource and action are required");
    auto app = applications.resolveApplication(r.tenantId, r.application);

    AccessRequest q;
    q.principalId = r.principalId.strip;
    q.groups = r.groups.map!(g => g.strip).filter!(g => g.length > 0).array;
    q.applicationId = app.id;
    q.resource = r.resource.strip;
    q.action = r.action.strip;
    q.attributes = cast(string[string]) r.attributes.dup;
    q.at = nowStdTime();
    auto d = evaluator.decide(q, policies.findByApplication(r.tenantId, app.id), assignments.findAll(r.tenantId));

    AuthorizationResult result;
    result.allowed = d.allowed;
    result.reason = d.reason;
    result.principalId = q.principalId;
    result.applicationId = app.id;
    result.resource = q.resource;
    result.action = q.action;
    result.matchedPolicyIds = d.matchedPolicyIds;
    result.matchedPolicyNames = d.matchedPolicyNames;
    result.candidatePolicies = d.candidatePolicies;
    result.evaluatedAt = q.at;

    if (r.record && recordDecisions) {
      DecisionRecord rec;
      stampCreated(rec, r.tenantId, UserId(q.principalId));
      rec.principalId = q.principalId;
      rec.groups = q.groups;
      rec.applicationId = app.id;
      rec.resource = q.resource;
      rec.action = q.action;
      rec.attributes = attributesText(q.attributes);
      rec.allowed = d.allowed;
      rec.reason = d.reason;
      rec.matchedPolicyIds = d.matchedPolicyIds;
      rec.channel = r.channel;
      decisions.save(rec);
      result.decisionId = rec.id;
      if (publisher !is null)
        publisher.publish(rec);
    }
    return result;
  }

  AuthorizationPolicy[] effectivePolicies(TenantId tenantId, string principalId, string[] groups,
    ManagedApplicationId applicationId = ManagedApplicationId.init) {
    auto now = nowStdTime();
    bool[string] assigned;
    foreach (a; assignments.findAll(tenantId))
      if (a.appliesTo(principalId, groups) && a.isEffective(now))
        assigned[a.policyId.value] = true;
    auto source = applicationId.isNull ? policies.findAll(tenantId) : policies.findByApplication(tenantId, applicationId);
    return source.filter!(p => p.isActive && (p.id.value in assigned) !is null).array;
  }
}
