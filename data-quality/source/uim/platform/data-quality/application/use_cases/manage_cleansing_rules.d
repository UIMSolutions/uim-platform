module application.use_cases.manage_cleansing_rules;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.cleansing_rule;
import domain.ports.cleansing_rule_repository;
import application.dto;

class ManageCleansingRulesUseCase
{
    private CleansingRuleRepository repo;

    this(CleansingRuleRepository repo)
    {
        this.repo = repo;
    }

    CommandResult create(CreateCleansingRuleRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.name.length == 0)
            return CommandResult("", "Rule name is required");
        if (req.fieldName.length == 0)
            return CommandResult("", "Field name is required");

        auto rule = CleansingRule();
        rule.id = randomUUID().toString();
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

    CommandResult update(UpdateCleansingRuleRequest req)
    {
        if (req.id.length == 0)
            return CommandResult("", "Rule ID is required");

        auto existing = repo.findById(req.id);
        if (existing is null)
            return CommandResult("", "Cleansing rule not found");
        if (existing.tenantId != req.tenantId)
            return CommandResult("", "Tenant mismatch");

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

    CommandResult remove(RuleId id, TenantId tenantId)
    {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult("", "Cleansing rule not found");
        if (existing.tenantId != tenantId)
            return CommandResult("", "Tenant mismatch");

        repo.remove(id, tenantId);
        return CommandResult(id, "");
    }

    CleansingRule* getById(RuleId id)
    {
        return repo.findById(id);
    }

    CleansingRule[] listByTenant(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    CleansingRule[] listActive(TenantId tenantId)
    {
        return repo.findActive(tenantId);
    }
}
