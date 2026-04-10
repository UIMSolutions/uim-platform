/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.manage.cleansing_rules;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.cleansing_rule;
// import uim.platform.data.quality.domain.ports.repositories.cleansing_rules;
// import uim.platform.data.quality.application.dto;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class ManageCleansingRulesUseCase : UIMUseCase {
  private CleansingRuleRepository repo;

  this(CleansingRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateCleansingRuleRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Rule name is required");
    if (req.fieldName.length == 0)
      return CommandResult(false, "", "Field name is required");

    auto rule = CleansingRule();
    rule.id = randomUUID();
    rule.tenantId = req.tenantId;
    rule.name = req.name;
    rule.description = req.description;
    rule.datasetPattern = req.datasetPattern;
    rule.fieldName = req.fieldName;
    rule.action = req.action;
    rule.status = RuleStatus.draft;
    rule.findPattern = req.findPattern;
    rule.replaceWith = req.replaceWith;
    rule.defaultValue = req.defaultValue;
    rule.lookupDataset = req.lookupDataset;
    rule.lookupField = req.lookupField;
    rule.trimWhitespace = req.trimWhitespace;
    rule.normalizeCase = req.normalizeCase;
    rule.caseMode = req.caseMode;
    rule.removeDiacritics = req.removeDiacritics;
    rule.category = req.category;
    rule.priority = req.priority;
    rule.createdAt = Clock.currStdTime();
    rule.updatedAt = rule.createdAt;

    repo.save(rule);
    return CommandResult(rule.id, "");
  }

  CommandResult update(UpdateCleansingRuleRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Rule ID is required");

    auto existing = repo.findById(req.id);
    if (existing is null)
      return CommandResult(false, "", "Cleansing rule not found");
    if (existing.tenantId != req.tenantId)
      return CommandResult(false, "", "Tenant mismatch");

    auto rule = *existing;
    rule.name = req.name;
    rule.description = req.description;
    rule.datasetPattern = req.datasetPattern;
    rule.fieldName = req.fieldName;
    rule.action = req.action;
    rule.status = req.status;
    rule.findPattern = req.findPattern;
    rule.replaceWith = req.replaceWith;
    rule.defaultValue = req.defaultValue;
    rule.lookupDataset = req.lookupDataset;
    rule.lookupField = req.lookupField;
    rule.trimWhitespace = req.trimWhitespace;
    rule.normalizeCase = req.normalizeCase;
    rule.caseMode = req.caseMode;
    rule.removeDiacritics = req.removeDiacritics;
    rule.category = req.category;
    rule.priority = req.priority;
    rule.updatedAt = Clock.currStdTime();

    repo.update(rule);
    return CommandResult(rule.id, "");
  }

  CommandResult remove(TenantId tenantId, RuleId id) {
    auto existing = repo.findById(id);
    if (existing is null)
      return CommandResult(false, "", "Cleansing rule not found");
    if (existing.tenantId != tenantId)
      return CommandResult(false, "", "Tenant mismatch");

    repo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }

  CleansingRule getById(RuleId id) {
    return repo.findById(id);
  }

  CleansingRule[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CleansingRule[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }
}
