/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageRetentionRulesUseCase {
    private IRetentionRuleRepository repo;

    this(IRetentionRuleRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createRetentionRule(CreateRetentionRuleRequest req) {
        import std.uuid : randomUUID;

        if (req.duration <= 0)
            return UsecaseResult(false, "", "Duration must be positive");

        RetentionRule rr;
        rr.id = RetentionRuleId(generateId);
        rr.tenantId = req.tenantId;
        rr.businessPurposeId = BusinessPurposeId(req.businessPurposeId);
        rr.legalGroundId = LegalGroundId(req.legalGroundId);
        rr.duration = req.duration;
        rr.periodUnit = req.periodUnit.toPeriodUnit();
        rr.actionOnExpiry = toDeletionActionType(req.actionOnExpiry);
        rr.isActive = true;
        rr.createdBy = req.createdBy;
        rr.createdAt = clockSeconds();

        repo.save(rr);
        return UsecaseResult(true, rr.id.value, "");
    }

    UsecaseResult updateRetentionRule(UpdateRetentionRuleRequest req) {
        auto rule = repo.findById(req.tenantId, req.ruleId);
        if (rule.isNull)
            return UsecaseResult(false, "", "Retention rule not found");

        if (req.duration > 0)
            rule.duration = req.duration;
        if (req.periodUnit.length > 0)
            rule.periodUnit = req.periodUnit.toPeriodUnit();
        if (req.actionOnExpiry.length > 0)
            rule.actionOnExpiry = toDeletionActionType(req.actionOnExpiry);
        rule.isActive = req.isActive;
        rule.updatedAt = clockSeconds();

        repo.update(rule);
        return UsecaseResult(true, rule.id.value, "");
    }

    bool hasById(TenantId tenantId, RetentionRuleId id) {
        return repo.existsById(tenantId, id);
    }

    RetentionRule getRetentionRule(TenantId tenantId, RetentionRuleId id) {
        return repo.findById(tenantId, id);
    }

    RetentionRule[] listRetentionRules(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    RetentionRule[] listRetentionRules(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }

    UsecaseResult deleteRetentionRule(TenantId tenantId, RetentionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return UsecaseResult(false, "", "Retention rule not found");

        repo.remove(rule);
        return UsecaseResult(true, rule.id.value, "");
    }

    private static DeletionActionType toDeletionActionType(string s) {
        switch (s) {
        case "block":
            return DeletionActionType.block;
        case "delete":
            return DeletionActionType.delete_;
        case "anonymize":
            return DeletionActionType.anonymize;
        default:
            return DeletionActionType.delete_;
        }
    }
}
