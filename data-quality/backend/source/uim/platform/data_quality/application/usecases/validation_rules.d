/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.validation_rules;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// Input (text form) ↔ entity.
ValidationRuleInput toInput(const ValidationRule r) {
  ValidationRuleInput i;
  i.name = r.name;
  i.description = r.description;
  i.datasetPattern = r.datasetPattern;
  i.fieldName = r.fieldName;
  i.ruleType = cast(string) r.ruleType;
  i.severity = cast(string) r.severity;
  i.status = cast(string) r.status;
  i.pattern = r.pattern;
  i.minValue = r.minValue;
  i.maxValue = r.maxValue;
  i.allowedValues = r.allowedValues.dup;
  i.caseSensitive = r.caseSensitive;
  i.crossFieldName = r.crossFieldName;
  i.operator = r.operator;
  i.expression = r.expression;
  i.referenceDataset = r.referenceDataset;
  i.referenceField = r.referenceField;
  i.category = r.category;
  i.priority = r.priority;
  return i;
}

void applyInput(ref ValidationRule r, const ValidationRuleInput i) {
  r.name = i.name.strip;
  r.description = i.description;
  r.datasetPattern = i.datasetPattern.strip;
  r.fieldName = i.fieldName.strip;
  r.ruleType = parseDomainEnumOr!RuleType(i.ruleType, RuleType.required, "rule type");
  r.severity = parseDomainEnumOr!RuleSeverity(i.severity, RuleSeverity.error, "severity");
  r.status = parseDomainEnumOr!RuleStatus(i.status, RuleStatus.draft, "status");
  r.pattern = i.pattern;
  r.minValue = i.minValue.strip;
  r.maxValue = i.maxValue.strip;
  r.allowedValues = i.allowedValues.map!(v => v.strip).filter!(v => v.length > 0).array;
  r.caseSensitive = i.caseSensitive;
  r.crossFieldName = i.crossFieldName.strip;
  r.operator = i.operator.strip.length ? i.operator.strip.toLower : "eq";
  r.expression = i.expression.strip;
  r.referenceDataset = i.referenceDataset.strip;
  r.referenceField = i.referenceField.strip;
  r.category = i.category.strip;
  r.priority = i.priority;
}

/// Execution order: priority, then name.
void sortRules(R)(ref R[] rules) {
  rules.sort!((a, b) => a.priority != b.priority ? a.priority < b.priority : a.name < b.name);
}

class ManageValidationRulesUseCase : DqInteractor, IManageValidationRules {
  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  ValidationRule createValidationRule(CreateValidationRuleRequest r) {
    auto id = idOrNew(r.id, "Rule ID");
    if (repos.validationRules.existsById(r.tenantId, ValidationRuleId(id)))
      throw DataQualityException.conflict("Validation rule '" ~ id ~ "' already exists");
    ValidationRule rule;
    stampCreated!(ValidationRule, ValidationRuleId)(rule, r.tenantId, r.actor, id, now);
    applyInput(rule, r.rule);
    rule.validate();
    repos.validationRules.save(rule);
    emit("validationRule.created", r.tenantId, id);
    return rule;
  }

  ValidationRule updateValidationRule(UpdateValidationRuleRequest r) {
    auto rule = getValidationRule(r.tenantId, ValidationRuleId(r.id));
    auto input = toInput(rule);
    r.changes.applyTo(input);
    applyInput(rule, input);
    rule.validate();
    stampUpdated(rule, r.actor, now);
    repos.validationRules.save(rule);
    return rule;
  }

  ValidationRule getValidationRule(TenantId t, ValidationRuleId id) {
    return required(repos.validationRules.findById(t, id), "Validation rule '" ~ id.value ~ "'");
  }

  ValidationRule[] listValidationRules(TenantId t) {
    auto rules = repos.validationRules.findAll(t);
    sortRules(rules);
    return rules;
  }

  ValidationRule[] applicableValidationRules(TenantId t, DatasetId ds) {
    auto rules = repos.validationRules.findAll(t).filter!(r => r.isActive && r.appliesTo(ds)).array;
    sortRules(rules);
    return rules;
  }

  void deleteValidationRule(TenantId t, ValidationRuleId id) {
    getValidationRule(t, id);
    repos.validationRules.removeById(t, id);
    emit("validationRule.deleted", t, id.value);
  }
}
