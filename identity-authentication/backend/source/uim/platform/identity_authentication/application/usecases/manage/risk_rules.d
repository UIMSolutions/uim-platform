/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.risk_rules;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Risk-based authentication rules and login simulation.
class ManageRiskRulesUseCase : IManageRiskRulesUseCase {
  protected IRiskRuleRepository repo;
  protected IUserRepository users;
  protected IGroupRepository groups;

  this(IRiskRuleRepository repo, IUserRepository users = null, IGroupRepository groups = null) {
    this.repo = repo;
    this.users = users;
    this.groups = groups;
  }

  RiskRule[] listRiskRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  RiskRule getRiskRule(TenantId tenantId, RiskRuleId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createRiskRule(RiskRuleDTO dto) {
    if (!dto.ruleId.isNull && repo.existsById(dto.tenantId, dto.ruleId))
      return conflict("Risk rule '" ~ dto.ruleId.value ~ "' already exists");
    auto rule = newEntity!RiskRule(dto.tenantId, dto.ruleId, dto.createdBy);
    string[] errors;
    apply(rule, dto, errors);
    errors ~= IdentityValidator.validate(rule);
    if (errors.length)
      return invalid(errors);
    repo.save(rule);
    return created(rule.id.value, "Risk rule created");
  }

  UsecaseResult updateRiskRule(RiskRuleDTO dto) {
    auto rule = repo.findById(dto.tenantId, dto.ruleId);
    if (rule.isNull)
      return notFound("Risk rule", dto.ruleId.value);
    string[] errors;
    apply(rule, dto, errors);
    errors ~= IdentityValidator.validate(rule);
    if (errors.length)
      return invalid(errors);
    touch(rule, dto.updatedBy);
    repo.update(rule);
    return succeeded(rule.id.value, "Risk rule updated");
  }

  UsecaseResult deleteRiskRule(TenantId tenantId, RiskRuleId id) {
    auto rule = repo.findById(tenantId, id);
    if (rule.isNull)
      return notFound("Risk rule", id.value);
    repo.remove(rule);
    return succeeded(id.value, "Risk rule deleted");
  }

  UsecaseResult assess(TenantId tenantId, UserId userId, RiskEvaluationContext ctx) {
    if (users is null)
      return rejected("Risk simulation is not available");
    auto user = users.findById(tenantId, userId);
    if (user.isNull)
      return notFound("User", userId.value);
    if (ctx.userGroups.length == 0)
      ctx.userGroups = groupKeysOf(groups, user);
    auto a = assessRisk(repo.findByTenant(tenantId), user, ctx);
    auto triggered = Json.emptyArray;
    foreach (name; a.triggeredRules)
      triggered ~= Json(name);
    return succeeded(userId.value, "Risk level " ~ enumValue(a.level), 200, Json.emptyObject
        .set("riskLevel", enumValue(a.level))
        .set("requiredMfa", enumValue(a.requiredMfa))
        .set("denied", a.denied)
        .set("triggeredRules", triggered));
  }

  protected void apply(ref RiskRule rule, const RiskRuleDTO dto, ref string[] errors) {
    assignIf(rule.name, dto.name.strip);
    rule.conditions = dto.conditions.map!(c => RiskCondition(c.conditionType.strip, c.operator_.strip, c.value.strip)).array;
    readEnum(dto.riskLevel, rule.riskLevel, "riskLevel", errors);
    readEnum(dto.requiredMfa, rule.requiredMfa, "requiredMfa", errors);
    rule.denyAccess = dto.denyAccess;
    rule.active = dto.active;
  }
}

///
unittest {
  mixin(ShowTest!("ManageRiskRulesUseCase"));

  auto users = new UserRepository();
  auto uc = new ManageRiskRulesUseCase(new RiskRuleRepository(), users);
  auto t = TenantId("t1");
  auto user = IAUser(t);
  users.save(user);

  RiskRuleDTO dto;
  dto.tenantId = t;
  dto.name = "external network";
  dto.conditions = [RiskCondition("ip_range", "not_in", "10.0.0.0/8")];
  dto.riskLevel = "high";
  dto.requiredMfa = "totp";
  assert(uc.createRiskRule(dto).isSuccess);

  RiskEvaluationContext ctx;
  ctx.ipAddress = "8.8.8.8";
  auto r = uc.assess(t, user.id, ctx);
  assert(r.data["riskLevel"].get!string == "high" && r.data["requiredMfa"].get!string == "totp");

  dto.riskLevel = "apocalyptic";
  assert(uc.createRiskRule(dto).code == 400);
  dto.riskLevel = "low";
  dto.conditions = null;
  assert(uc.createRiskRule(dto).code == 400);
}
