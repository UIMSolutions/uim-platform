/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.policies;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Authorization policy management and access simulation.
class ManagePoliciesUseCase : IManagePoliciesUseCase {
  protected IPolicyRepository repo;
  protected IUserRepository users;
  protected IGroupRepository groups;

  this(IPolicyRepository repo, IUserRepository users = null, IGroupRepository groups = null) {
    this.repo = repo;
    this.users = users;
    this.groups = groups;
  }

  AuthorizationPolicy[] listPolicies(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AuthorizationPolicy[] listByApplication(TenantId tenantId, ApplicationId appId) {
    return repo.findByApplication(tenantId, appId);
  }

  AuthorizationPolicy getPolicy(TenantId tenantId, PolicyId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createPolicy(PolicyDTO dto) {
    if (!dto.policyId.isNull && repo.existsById(dto.tenantId, dto.policyId))
      return conflict("Policy '" ~ dto.policyId.value ~ "' already exists");
    auto policy = newEntity!AuthorizationPolicy(dto.tenantId, dto.policyId, dto.createdBy);
    apply(policy, dto);
    auto errors = IdentityValidator.validate(policy);
    if (errors.length)
      return invalid(errors);
    repo.save(policy);
    return created(policy.id.value, "Policy created");
  }

  UsecaseResult updatePolicy(PolicyDTO dto) {
    auto policy = repo.findById(dto.tenantId, dto.policyId);
    if (policy.isNull)
      return notFound("Policy", dto.policyId.value);
    apply(policy, dto);
    auto errors = IdentityValidator.validate(policy);
    if (errors.length)
      return invalid(errors);
    touch(policy, dto.updatedBy);
    repo.update(policy);
    return succeeded(policy.id.value, "Policy updated");
  }

  UsecaseResult deletePolicy(TenantId tenantId, PolicyId id) {
    auto policy = repo.findById(tenantId, id);
    if (policy.isNull)
      return notFound("Policy", id.value);
    repo.remove(policy);
    return succeeded(id.value, "Policy deleted");
  }

  UsecaseResult evaluateAccess(TenantId tenantId, ApplicationId appId, UserId userId, PolicyEvaluationContext ctx) {
    if (users is null)
      return rejected("Access evaluation is not available");
    auto user = users.findById(tenantId, userId);
    if (user.isNull)
      return notFound("User", userId.value);
    if (ctx.userGroups.length == 0)
      ctx.userGroups = groupKeysOf(groups, user);

    auto denying = findDenyingPolicies(repo.findByApplication(tenantId, appId), user, ctx);
    auto names = Json.emptyArray;
    foreach (p; denying)
      names ~= Json(p.name);
    bool granted = denying.length == 0 && user.isActive;
    return succeeded(userId.value, granted ? "Access granted" : "Access denied", 200,
      Json.emptyObject.set("granted", granted).set("denyingPolicies", names));
  }

  protected void apply(ref AuthorizationPolicy policy, const PolicyDTO dto) {
    assignIf(policy.name, dto.name.strip);
    policy.description = dto.description;
    policy.rules = dto.rules.map!(r => PolicyRule(r.attribute.strip, r.operator_.strip, r.value.strip)).array;
    policy.applicationIds = cleanList(dto.applicationIds);
    policy.active = dto.active;
  }
}

///
unittest {
  mixin(ShowTest!("ManagePoliciesUseCase"));

  auto users = new UserRepository();
  auto uc = new ManagePoliciesUseCase(new PolicyRepository(), users);
  auto t = TenantId("t1");
  auto user = IAUser(t);
  user.groupIds = [GroupId("g-admins")];
  users.save(user);

  PolicyDTO dto;
  dto.tenantId = t;
  dto.name = "Admins only";
  dto.rules = [PolicyRule("group", "in", "g-admins")];
  dto.applicationIds = ["app-1"];
  assert(uc.createPolicy(dto).isSuccess);
  assert(uc.listByApplication(t, ApplicationId("app-1")).length == 1);
  assert(uc.listByApplication(t, ApplicationId("app-2")).length == 0);

  PolicyEvaluationContext ctx;
  auto r = uc.evaluateAccess(t, ApplicationId("app-1"), user.id, ctx);
  assert(r.data["granted"].get!bool);

  dto.rules = [PolicyRule("group", "flies", "")];
  assert(uc.createPolicy(dto).code == 400);
}
