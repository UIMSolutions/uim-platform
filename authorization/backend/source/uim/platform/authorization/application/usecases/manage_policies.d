/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.application.usecases.manage_policies;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Use case: authorization policies.
///
/// Rules: names are unique per application · base policies keep resource,
/// action and conditions (derive a custom policy instead) · deleting a policy
/// removes its assignments · base policies are seeded idempotently.
class ManagePoliciesUseCase : IManagePolicies {
  protected IPolicyRepository policies;
  protected IApplicationRepository applications;
  protected IAssignmentRepository assignments;

  this(IPolicyRepository policies, IApplicationRepository applications, IAssignmentRepository assignments) {
    this.policies = policies;
    this.applications = applications;
    this.assignments = assignments;
  }

  AuthorizationPolicy createPolicy(CreatePolicyRequest r) {
    AuthorizationPolicy p;
    p.applicationId = r.applicationId;
    p.name = r.name.strip;
    p.description = r.description;
    p.resource = r.resource.strip;
    p.action = r.action.strip;
    p.conditions = r.conditions.dup;
    p.kind = r.kind;
    p.status = r.status;
    p.validate();
    required(applications.findById(r.tenantId, p.applicationId), "Application '" ~ p.applicationId.value ~ "'");
    if (!policies.findByName(r.tenantId, p.applicationId, p.name).isNull)
      throw AuthorizationException.conflict("Policy '" ~ p.name ~ "' already exists in this application");
    stampCreated(p, r.tenantId, r.actor);
    policies.save(p);
    return p;
  }

  AuthorizationPolicy updatePolicy(UpdatePolicyRequest r) {
    auto p = getPolicy(r.tenantId, r.id);
    if (p.isBase && (r.fields.has("resource") && r.resource.strip != p.resource
        || r.fields.has("action") && r.action.strip != p.action
        || r.fields.has("conditions") && conditionsText(r.conditions) != conditionsText(p.conditions)))
      throw AuthorizationException.ruleViolation("Base policy '" ~ p.name
          ~ "' cannot change resource, action or conditions — create a custom policy instead");
    if (r.fields.has("name") && r.name.strip != p.name) {
      if (p.isBase)
        throw AuthorizationException.ruleViolation("Base policy '" ~ p.name ~ "' cannot be renamed");
      if (!policies.findByName(r.tenantId, p.applicationId, r.name.strip).isNull)
        throw AuthorizationException.conflict("Policy '" ~ r.name.strip ~ "' already exists in this application");
      p.name = r.name.strip;
    }
    if (r.fields.has("description"))
      p.description = r.description;
    if (r.fields.has("resource"))
      p.resource = r.resource.strip;
    if (r.fields.has("action"))
      p.action = r.action.strip;
    if (r.fields.has("conditions"))
      p.conditions = r.conditions.dup;
    if (r.fields.has("status"))
      p.status = parseDomainEnum!PolicyStatus(r.status, "status");
    p.validate();
    stampUpdated(p, r.actor);
    policies.save(p);
    return p;
  }

  AuthorizationPolicy getPolicy(TenantId tenantId, PolicyId id) {
    return required(policies.findById(tenantId, id), "Policy '" ~ id.value ~ "'");
  }

  AuthorizationPolicy[] listPolicies(TenantId tenantId) {
    return policies.findAll(tenantId);
  }

  AuthorizationPolicy[] listPolicies(TenantId tenantId, ManagedApplicationId applicationId) {
    return policies.findByApplication(tenantId, applicationId);
  }

  AuthorizationPolicy enablePolicy(TenantId tenantId, PolicyId id, UserId actor) {
    auto p = getPolicy(tenantId, id);
    p.enable();
    stampUpdated(p, actor);
    policies.save(p);
    return p;
  }

  AuthorizationPolicy disablePolicy(TenantId tenantId, PolicyId id, UserId actor) {
    auto p = getPolicy(tenantId, id);
    p.disable();
    stampUpdated(p, actor);
    policies.save(p);
    return p;
  }

  void deletePolicy(TenantId tenantId, PolicyId id) {
    auto p = getPolicy(tenantId, id);
    foreach (a; assignments.findByPolicy(tenantId, p.id))
      assignments.removeById(tenantId, a.id);
    policies.removeById(tenantId, p.id);
  }

  AuthorizationPolicy[] seedBasePolicies(TenantId tenantId, ManagedApplicationId applicationId, UserId actor) {
    required(applications.findById(tenantId, applicationId), "Application '" ~ applicationId.value ~ "'");
    foreach (t; basePolicyTemplates) {
      if (!policies.findByName(tenantId, applicationId, t.name).isNull)
        continue;
      CreatePolicyRequest r;
      r.tenantId = tenantId;
      r.actor = actor;
      r.applicationId = applicationId;
      r.name = t.name;
      r.description = t.description;
      r.resource = t.resource;
      r.action = t.action;
      r.kind = PolicyKind.base;
      createPolicy(r);
    }
    return policies.findByApplication(tenantId, applicationId).filter!(p => p.isBase).array;
  }
}
