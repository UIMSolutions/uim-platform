/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.unification_rules;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageUnificationRulesUseCase {
  protected IUnificationRuleRepository repo;

  this(IUnificationRuleRepository repo) { this.repo = repo; }

  UsecaseResult create(CreateUnificationRuleRequest r) {
    UnificationRule rule;
    rule.id = UnificationRuleId(r.id.length > 0 ? r.id : currentTimestamp());
    rule.tenantId = R.tenantId;
    rule.name = r.name;
    rule.description = r.description;
    rule.priority = r.priority;
    rule.model = r.model.length > 0 ? cast(UnificationModel) r.model : UnificationModel.deterministic;
    rule.identifierAttributes = r.identifierAttributes;
    rule.unique_ = r.unique_;
    rule.triggerMerge = r.triggerMerge;
    rule.preventMerge = r.preventMerge;
    rule.active = true;
    initEntity(rule);

    auto err = ComposerValidator.validateUnificationRule(rule);
    if (err !is null) return UsecaseResult(false, rule.id.value, err);

    repo.save(rule);
    return UsecaseResult(true, rule.id.value, null);
  }

  UnificationRule[] list(TenantId tenantId) {
    return repo.findByPriority(TenantId(tenantId));
  }

  UnificationRule getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), UnificationRuleId(id));
  }

  UsecaseResult update(UpdateUnificationRuleRequest r) {
    auto rule = repo.findById(R.tenantId, UnificationRuleId(r.id));
    if (rule.isNull) return UsecaseResult(false, r.id, "Rule not found");

    if (r.name.length > 0)        rule.name = r.name;
    if (r.description.length > 0) rule.description = r.description;
    if (r.priority > 0)            rule.priority = r.priority;
    if (r.model.length > 0)        rule.model = cast(UnificationModel) r.model;
    if (r.identifierAttributes.length > 0) rule.identifierAttributes = r.identifierAttributes;
    rule.unique_ = r.unique_;
    rule.triggerMerge = r.triggerMerge;
    rule.preventMerge = r.preventMerge;
    rule.active = r.active;

    repo.update(rule);
    return UsecaseResult(true, rule.id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    auto rule = repo.findById(TenantId(tenantId), UnificationRuleId(id));
    if (rule.isNull) return UsecaseResult(false, id, "Rule not found");
    repo.remove(TenantId(tenantId), UnificationRuleId(id));
    return UsecaseResult(true, id, null);
  }
}
