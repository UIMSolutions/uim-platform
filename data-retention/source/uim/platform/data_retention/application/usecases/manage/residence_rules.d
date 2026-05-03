module uim.platform.data_retention.application.usecases.manage.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageResidenceRulesUseCase { // TODO: UIMUseCase {
    private ResidenceRuleRepository repo;

    this(ResidenceRuleRepository repo) { this.repo = repo; }

    CommandResult create(CreateResidenceRuleRequest req) {
        import std.uuid : randomUUID;
        if (req.duration <= 0) return CommandResult(false, "", "Duration must be positive");

        ResidenceRule rr;
        rr.id = ResidenceRuleId(randomUUID().toString());
        rr.tenantId = req.tenantId;
        rr.businessPurposeId = BusinessPurposeId(req.businessPurposeId);
        rr.legalGroundId = LegalGroundId(req.legalGroundId);
        rr.duration = req.duration;
        rr.periodUnit = parsePeriodUnit(req.periodUnit);
        rr.isActive = true;
        rr.createdBy = req.createdBy;
        rr.createdAt = clockSeconds();

        repo.save(rr);
        return CommandResult(true, rr.id.value, "");
    }

    CommandResult update(string id, UpdateResidenceRuleRequest req) { return update(ResidenceRuleId(id), req); }

    CommandResult update(ResidenceRuleId id, UpdateResidenceRuleRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Residence rule not found");

        auto rr = repo.findById(id);
        if (req.duration > 0) rr.duration = req.duration;
        if (req.periodUnit.length > 0) rr.periodUnit = parsePeriodUnit(req.periodUnit);
        rr.isActive = req.isActive;
        rr.updatedAt = clockSeconds();

        repo.update(rr);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(ResidenceRuleId(id)); }
    bool hasById(ResidenceRuleId id) { return repo.existsById(id); }
    ResidenceRule getById(string id) { return getById(ResidenceRuleId(id)); }
    ResidenceRule getById(ResidenceRuleId id) { return repo.findById(id); }
    ResidenceRule[] list(TenantId tenantId) { return list(TenantId(tenantId)); }
    ResidenceRule[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    ResidenceRule[] listByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }
    CommandResult remove(string id) { return remove(ResidenceRuleId(id)); }
    CommandResult remove(ResidenceRuleId id) { repo.removeById(id); return CommandResult(true, id.value, ""); }

    private static PeriodUnit parsePeriodUnit(string s) {
        switch (s) {
            case "days": return PeriodUnit.days;
            case "weeks": return PeriodUnit.weeks;
            case "months": return PeriodUnit.months;
            case "years": return PeriodUnit.years;
            default: return PeriodUnit.years;
        }
    }
}
