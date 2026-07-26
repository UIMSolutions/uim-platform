module uim.platform.authorization.application.usecases.manage_policies;

import std.algorithm : filter;
import std.algorithm.searching : canFind;
import std.array : array;
import std.uuid : randomUUID;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class ManagePoliciesUseCase {
  private AuthorizationRepository repo;

  this(AuthorizationRepository repo) {
    this.repo = repo;
  }

  UseCaseResult createPolicy(CreatePolicyRequest req) {
    if (req.name.isEmpty || req.resource.isEmpty || req.action.isEmpty) {
      return UseCaseResult(false, "", "name, resource and action are required");
    }

    auto app = repo.findApplicationById(req.tenantId, req.applicationId);
    if (app.id.isEmpty) {
      return UseCaseResult(false, "", "Referenced application not found");
    }

    AuthorizationPolicy p;
    p.id = randomUUID().toString();
    p.tenantId = req.tenantId;
    p.applicationId = req.applicationId;
    p.name = req.name;
    p.description = req.description;
    p.resource = req.resource;
    p.action = req.action;
    p.isBasePolicy = req.isBasePolicy;
    foreach (c; req.conditions) {
      p.conditions ~= PolicyCondition(c.attribute, c.op, c.value);
    }
    p.createdAt = currentTimestamp();
    p.updatedAt = p.createdAt;

    repo.savePolicy(p);
    return UseCaseResult(true, p.id, "");
  }

  UseCaseResult updatePolicy(UpdatePolicyRequest req) {
    auto p = repo.findPolicyById(req.tenantId, req.policyId);
    if (p.id.isEmpty) {
      return UseCaseResult(false, "", "Policy not found");
    }

    if (req.description.length) p.description = req.description;
    if (req.resource.length) p.resource = req.resource;
    if (req.action.length) p.action = req.action;
    if (req.conditions.length) {
      p.conditions = [];
      foreach (c; req.conditions) {
        p.conditions ~= PolicyCondition(c.attribute, c.op, c.value);
      }
    }
    p.updatedAt = currentTimestamp();

    repo.savePolicy(p);
    return UseCaseResult(true, p.id, "");
  }

  UseCaseResult deletePolicy(string tenantId, string policyId) {
    auto p = repo.findPolicyById(tenantId, policyId);
    if (p.id.isEmpty) {
      return UseCaseResult(false, "", "Policy not found");
    }

    repo.deletePolicy(tenantId, policyId);
    return UseCaseResult(true, policyId, "");
  }

  AuthorizationPolicy[] listPolicies(string tenantId) {
    return repo.listPolicies(tenantId);
  }

  AuthorizationPolicy[] listBasePolicies(string tenantId) {
    return repo.listBasePolicies(tenantId);
  }

  AuthorizationPolicy getPolicy(string tenantId, string policyId) {
    return repo.findPolicyById(tenantId, policyId);
  }

  AuthorizationPolicy[] seedBasePolicies(string tenantId, string applicationId) {
    auto app = repo.findApplicationById(tenantId, applicationId);
    if (app.id.isEmpty) {
      return [];
    }

    auto existingBase = repo
      .listBasePolicies(tenantId)
      .filter!(p => p.applicationId == applicationId)
      .array;

    static struct BaseTemplate {
      string name;
      string description;
      string resource;
      string action;
    }

    auto templates = [
      BaseTemplate("admin", "Administrative full access", "*", "*"),
      BaseTemplate("reader", "Read-only access", "*", "Read"),
      BaseTemplate("support", "Support read access for incident-like resources", "Incident", "Read")
    ];

    foreach (t; templates) {
      if (existingBase.map!(p => p.name).array.canFind(t.name)) {
        continue;
      }

      CreatePolicyRequest req;
      req.tenantId = tenantId;
      req.applicationId = applicationId;
      req.name = t.name;
      req.description = t.description;
      req.resource = t.resource;
      req.action = t.action;
      req.isBasePolicy = true;
      createPolicy(req);
    }

    return repo
      .listBasePolicies(tenantId)
      .filter!(p => p.applicationId == applicationId)
      .array;
  }
}
