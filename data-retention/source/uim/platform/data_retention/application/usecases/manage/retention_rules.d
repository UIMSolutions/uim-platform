module uim.platform.data_retention.application.usecases.manage.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageRetentionRulesUseCase : UIMUseCase {
    private RetentionRuleRepository repo;

    this(RetentionRuleRepository repo) { this.repo = repo; }

    CommandResult create(CreateRetentionRuleRequest req) {
        import std.uuid : randomUUID;
        if (req.duration <= 0) return CommandResult(false, "", "Duration must be positive");

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

    CommandResult update(string id, UpdateRetentionRuleRequest req) { return update(RetentionRuleId(id), req); }

    CommandResult update(RetentionRuleId id, UpdateRetentionRuleRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Retention rule not found");

        auto rr = repo.findById(id);
        if (req.duration > 0) rr.duration = req.duration;
        if (req.periodUnit.length > 0) rr.periodUnit = parsePeriodUnit(req.periodUnit);
        if (req.actionOnExpiry.length > 0) rr.actionOnExpiry = parseDeletionActionType(req.actionOnExpiry);
        rr.isActive = req.isActive;
        rr.updatedAt = clockSeconds();

        repo.update(rr);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(RetentionRuleId(id)); }
    bool hasById(RetentionRuleId id) { return repo.existsById(id); }
    RetentionRule getById(string id) { return getById(RetentionRuleId(id)); }
    RetentionRule getById(RetentionRuleId id) { return repo.findById(id); }
    RetentionRule[] list(string tenantId) { return list(TenantId(tenantId)); }
    RetentionRule[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    RetentionRule[] listByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }
    CommandResult remove(string id) { return remove(RetentionRuleId(id)); }
    CommandResult remove(RetentionRuleId id) { repo.remove(id); return CommandResult(true, id.value, ""); }

    private static PeriodUnit parsePeriodUnit(string s) {
        switch (s) {
            case "days": return PeriodUnit.days;
            case "weeks": return PeriodUnit.weeks;
            case "months": return PeriodUnit.months;
            case "years": return PeriodUnit.years;
            default: return PeriodUnit.years;
        }
    }

    private static DeletionActionType parseDeletionActionType(string s) {
        switch (s) {
            case "block": return DeletionActionType.block;
            case "delete": return DeletionActionType.delete_;
            case "anonymize": return DeletionActionType.anonymize;
            default: return DeletionActionType.delete_;
        }
    }
}
