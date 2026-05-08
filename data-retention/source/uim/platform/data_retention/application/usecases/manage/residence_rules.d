module uim.platform.data_retention.application.usecases.manage.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageResidenceRulesUseCase { // TODO: UIMUseCase {
    private ResidenceRuleRepository repo;

    this(ResidenceRuleRepository repo) {
        this.repo = repo;
    }

    CommandResult createResidenceRule(CreateResidenceRuleRequest req) {
        import std.uuid : randomUUID;

        if (req.duration <= 0)
            return CommandResult(false, "", "Duration must be positive");

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

    CommandResult updateResidenceRule(UpdateResidenceRuleRequest req) {
        auto rule = repo.findById(req.tenantId, req.id);
        if (!repo.existsById(req.tenantId, req.id))
            return CommandResult(false, "", "Residence rule not found");

        if (req.duration > 0)
            rule.duration = req.duration;
        if (req.periodUnit.length > 0)
            rule.periodUnit = parsePeriodUnit(req.periodUnit);
        rule.isActive = req.isActive;
        rule.updatedAt = clockSeconds();

        repo.update(rule);
        return CommandResult(true, rule.id.value, "");
    }

    bool hasResidenceRule(TenantId tenantId, ResidenceRuleId id) {
        return repo.existsById(tenantId, id);
    }

    ResidenceRule getResidenceRule(TenantId tenantId, ResidenceRuleId id) {
        return repo.findById(tenantId, id);
    }

    ResidenceRule[] listResidenceRules(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    ResidenceRule[] listResidenceRules(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }

    CommandResult deleteResidenceRule(TenantId tenantId, ResidenceRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.id.isEmpty)
            return CommandResult(false, "", "Residence rule not found");

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
}
