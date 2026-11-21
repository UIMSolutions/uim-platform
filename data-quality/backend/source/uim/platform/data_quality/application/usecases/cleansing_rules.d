/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.cleansing_rules;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

CleansingRuleInput toInput(const CleansingRule r) {
  CleansingRuleInput i;
  i.name = r.name;
  i.description = r.description;
  i.datasetPattern = r.datasetPattern;
  i.fieldName = r.fieldName;
  i.action = cast(string) r.action;
  i.status = cast(string) r.status;
  i.findPattern = r.findPattern;
  i.replaceWith = r.replaceWith;
  i.defaultValue = r.defaultValue;
  i.lookupDataset = r.lookupDataset;
  i.lookupKeyField = r.lookupKeyField;
  i.lookupValueField = r.lookupValueField;
  i.sourceField = r.sourceField;
  i.category = r.category;
  i.priority = r.priority;
  return i;
}

void applyInput(ref CleansingRule r, const CleansingRuleInput i) {
  r.name = i.name.strip;
  r.description = i.description;
  r.datasetPattern = i.datasetPattern.strip;
  r.fieldName = i.fieldName.strip;
  r.action = parseDomainEnumOr!CleansingAction(i.action, CleansingAction.trim, "action");
  r.status = parseDomainEnumOr!RuleStatus(i.status, RuleStatus.draft, "status");
  r.findPattern = i.findPattern;
  r.replaceWith = i.replaceWith;
  r.defaultValue = i.defaultValue;
  r.lookupDataset = i.lookupDataset.strip;
  r.lookupKeyField = i.lookupKeyField.strip;
  r.lookupValueField = i.lookupValueField.strip;
  r.sourceField = i.sourceField.strip;
  r.category = i.category.strip;
  r.priority = i.priority;
}

class ManageCleansingRulesUseCase : DqInteractor, IManageCleansingRules {
  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  CleansingRule createCleansingRule(CreateCleansingRuleRequest r) {
    auto id = idOrNew(r.id, "Rule ID");
    if (repos.cleansingRules.existsById(r.tenantId, CleansingRuleId(id)))
      throw DataQualityException.conflict("Cleansing rule '" ~ id ~ "' already exists");
    CleansingRule rule;
    stampCreated!(CleansingRule, CleansingRuleId)(rule, r.tenantId, r.actor, id, now);
    applyInput(rule, r.rule);
    rule.validate();
    repos.cleansingRules.save(rule);
    emit("cleansingRule.created", r.tenantId, id);
    return rule;
  }

  CleansingRule updateCleansingRule(UpdateCleansingRuleRequest r) {
    auto rule = getCleansingRule(r.tenantId, CleansingRuleId(r.id));
    auto input = toInput(rule);
    r.changes.applyTo(input);
    applyInput(rule, input);
    rule.validate();
    stampUpdated(rule, r.actor, now);
    repos.cleansingRules.save(rule);
    return rule;
  }

  CleansingRule getCleansingRule(TenantId t, CleansingRuleId id) {
    return required(repos.cleansingRules.findById(t, id), "Cleansing rule '" ~ id.value ~ "'");
  }

  CleansingRule[] listCleansingRules(TenantId t) {
    auto rules = repos.cleansingRules.findAll(t);
    sortRules(rules);
    return rules;
  }

  CleansingRule[] applicableCleansingRules(TenantId t, DatasetId ds) {
    auto rules = repos.cleansingRules.findAll(t).filter!(r => r.isActive && r.appliesTo(ds)).array;
    sortRules(rules);
    return rules;
  }

  void deleteCleansingRule(TenantId t, CleansingRuleId id) {
    getCleansingRule(t, id);
    foreach (job; repos.cleansingJobs.findByStatus(t, JobStatus.pending))
      if (job.ruleIds.canFind(id))
        throw DataQualityException.ruleViolation("Cleansing rule '" ~ id.value ~ "' is used by pending job '" ~ job.id.value ~ "'");
    repos.cleansingRules.removeById(t, id);
    emit("cleansingRule.deleted", t, id.value);
  }
}
