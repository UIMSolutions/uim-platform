module uim.platform.data_retention.application.usecases.manage.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageRetentionRulesUseCase { // TODO: UIMUseCase {
    private RetentionRuleRepository repo;

    this(RetentionRuleRepository repo) {
        this.repo = repo;
    }

    CommandResult createRetentionRule(CreateRetentionRuleRequest req) {
        import std.uuid : randomUUID;

        if (req.duration <= 0)
            return CommandResult(false, "", "Duration must be positive");

        RetentionRule rr;
        rr.id = RetentionRuleId(randomUUID().toString());
        rr.tenantId = req.tenantId;
        rr.businessPurposeId = BusinessPurposeId(req.businessPurposeId);
        rr.legalGroundId = LegalGroundId(req.legalGroundId);
        rr.duration = req.duration;
        rr.periodUnit = parsePeriodUnit(req.periodUnit);
        rr.actionOnExpiry = parseDeletionActionType(req.actionOnExpiry);
        rr.isActive = true;
        rr.createdBy = req.createdBy;
        rr.createdAt = clockSeconds();

        repo.save(rr);
        return CommandResult(true, rr.id.value, "");
    }

    CommandResult updateRetentionRule(UpdateRetentionRuleRequest req) {
        auto rule = repo.findById(req.tenantId, req.id);
        if (rule.isNull)
            return CommandResult(false, "", "Retention rule not found");

        if (req.duration > 0)
            rule.duration = req.duration;
        if (req.periodUnit.length > 0)
            rule.periodUnit = parsePeriodUnit(req.periodUnit);
        if (req.actionOnExpiry.length > 0)
            rule.actionOnExpiry = parseDeletionActionType(req.actionOnExpiry);
        rule.isActive = req.isActive;
        rule.updatedAt = clockSeconds();

        repo.update(rule);
        return CommandResult(true, rule.id.value, "");
    }

    bool hasById(RetentionRuleId id) {
        return repo.existsById(id);
    }

    RetentionRule getById(RetentionRuleId id) {
        return repo.findById(tenantId, id);
    }

    RetentionRule[] list(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    RetentionRule[] listByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }

    CommandResult deleteRetentionRule(RetentionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Retention rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }

    private static PeriodUnit parsePeriodUnit(string s) {
        switch (s) {
        case "days":
            return PeriodUnit.days;
        case "weeks":
            return PeriodUnit.weeks;
        case "months":
            return PeriodUnit.months;
        case "years":
            return PeriodUnit.years;
        default:
            return PeriodUnit.years;
        }
    }

    private static DeletionActionType parseDeletionActionType(string s) {
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
