/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage_personalization;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageSubstitutionRulesUseCase : IManageSubstitutionRules {
  protected ISubstitutionRuleRepository rules;
  protected ITaskDefinitionRepository definitions;

  this(ISubstitutionRuleRepository rules, ITaskDefinitionRepository definitions) {
    this.rules = rules;
    this.definitions = definitions;
  }

  SubstitutionRule[] listSubstitutionRules(TenantId tenantId) {
    return rules.findAll(tenantId);
  }

  SubstitutionRule getSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
    return rules.findById(tenantId, id).required("Substitution rule '" ~ id.value ~ "'");
  }

  SubstitutionRule createSubstitutionRule(CreateSubstitutionRuleRequest r) {
    SubstitutionRule s;
    stampCreated!(SubstitutionRule, SubstitutionRuleId)(s, r.tenantId, r.actor, r.id);
    if (rules.existsById(r.tenantId, s.id))
      throw TaskCenterException.conflict("Substitution rule '" ~ s.id.value ~ "' already exists");
    s.userId = r.userId.strip.length > 0 ? r.userId.strip : r.actor.value;
    requireOwner(s.userId, r.actor, r.privileged, "substitution rule");
    s.substituteId = r.substituteId.strip;
    s.definitionId = definitionOf(r.tenantId, r.definitionId);
    s.status = parseDomainEnumOr!SubstitutionStatus(r.status, SubstitutionStatus.active, "status");
    s.startDate = r.startDate.strip;
    s.endDate = r.endDate.strip;
    s.isAutoForward = r.isAutoForward;
    s.validate();
    checkForwardingCycle(rules.findAll(r.tenantId), s, todayIso());
    rules.save(s);
    return s;
  }

  SubstitutionRule updateSubstitutionRule(UpdateSubstitutionRuleRequest r) {
    auto s = getSubstitutionRule(r.tenantId, r.id);
    requireOwner(s.userId, r.actor, r.privileged, "substitution rule");
    r.substituteId.applyTo(s.substituteId);
    if (r.definitionId.isSet)
      s.definitionId = definitionOf(r.tenantId, r.definitionId.value);
    applyEnum(r.status, s.status, "status");
    r.startDate.applyTo(s.startDate);
    r.endDate.applyTo(s.endDate);
    r.isAutoForward.applyTo(s.isAutoForward);
    s.validate();
    checkForwardingCycle(rules.findAll(r.tenantId), s, todayIso());
    stampUpdated(s, r.actor);
    rules.save(s);
    return s;
  }

  void deleteSubstitutionRule(TenantId tenantId, SubstitutionRuleId id, UserId actor, bool privileged) {
    auto s = getSubstitutionRule(tenantId, id);
    requireOwner(s.userId, actor, privileged, "substitution rule");
    rules.removeById(tenantId, id);
  }

  protected TaskDefinitionId definitionOf(TenantId tenantId, string id) {
    if (id.strip.length == 0)
      return TaskDefinitionId.init;
    return definitions.findById(tenantId, TaskDefinitionId(id.strip)).required("Task definition '" ~ id ~ "'").id;
  }
}

class ManageUserTaskFiltersUseCase : IManageUserTaskFilters {
  protected IUserTaskFilterRepository filters;

  this(IUserTaskFilterRepository filters) {
    this.filters = filters;
  }

  UserTaskFilter[] listUserTaskFilters(TenantId tenantId) {
    return filters.findAll(tenantId);
  }

  UserTaskFilter getUserTaskFilter(TenantId tenantId, UserTaskFilterId id) {
    return filters.findById(tenantId, id).required("Filter '" ~ id.value ~ "'");
  }

  UserTaskFilter createUserTaskFilter(CreateUserTaskFilterRequest r) {
    UserTaskFilter f;
    stampCreated!(UserTaskFilter, UserTaskFilterId)(f, r.tenantId, r.actor, r.id);
    if (filters.existsById(r.tenantId, f.id))
      throw TaskCenterException.conflict("Filter '" ~ f.id.value ~ "' already exists");
    f.userId = r.userId.strip.length > 0 ? r.userId.strip : r.actor.value;
    requireOwner(f.userId, r.actor, r.privileged, "filter");
    f.name = r.name.strip;
    f.description = r.description;
    f.criteria = parseCriteria(r.criteria);
    f.isDefault = r.isDefault;
    f.validate();
    ensureUniqueName(f);
    if (f.isDefault)
      clearOtherDefaults(f);
    filters.save(f);
    return f;
  }

  UserTaskFilter updateUserTaskFilter(UpdateUserTaskFilterRequest r) {
    auto f = getUserTaskFilter(r.tenantId, r.id);
    requireOwner(f.userId, r.actor, r.privileged, "filter");
    r.name.applyTo(f.name);
    r.description.applyTo(f.description);
    if (r.criteria.isSet)
      f.criteria = parseCriteria(r.criteria.value);
    r.isDefault.applyTo(f.isDefault);
    f.name = f.name.strip;
    f.validate();
    ensureUniqueName(f);
    if (f.isDefault)
      clearOtherDefaults(f);
    stampUpdated(f, r.actor);
    filters.save(f);
    return f;
  }

  void deleteUserTaskFilter(TenantId tenantId, UserTaskFilterId id, UserId actor, bool privileged) {
    auto f = getUserTaskFilter(tenantId, id);
    requireOwner(f.userId, actor, privileged, "filter");
    filters.removeById(tenantId, id);
  }

  protected void ensureUniqueName(const UserTaskFilter f) {
    foreach (other; filters.findByUser(f.tenantId, f.userId))
      if (other.id != f.id && other.name == f.name)
        throw TaskCenterException.conflict(f.userId ~ " already has a filter named '" ~ f.name ~ "'");
  }

  protected void clearOtherDefaults(const UserTaskFilter f) {
    foreach (other; filters.findByUser(f.tenantId, f.userId))
      if (other.id != f.id && other.isDefault) {
        other.isDefault = false;
        filters.save(other);
      }
  }
}
