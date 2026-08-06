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

        auto rr = ResidenceRule(req.tenantId);
        rr.businessPurposeId = req.purposeId;
        rr.legalGroundId = LegalGroundId(req.legalGroundId);
        rr.duration = req.duration;
        rr.periodUnit = req.periodUnit.toPeriodUnit;
        rr.isActive = true;

        repo.save(rr);
        return CommandResult(true, rr.id.value, "");
    }

    CommandResult updateResidenceRule(UpdateResidenceRuleRequest req) {
        auto rule = repo.findById(req.tenantId, req.ruleId);
        if (rule.isNull)
            return CommandResult(false, "", "Residence rule not found");

        if (req.duration > 0)
            rule.duration = req.duration;

        if (req.periodUnit.length > 0)
            rule.periodUnit = req.periodUnit.toPeriodUnit;

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
        return repo.findByTenant(tenantId);
    }

    ResidenceRule[] listResidenceRules(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }

    CommandResult deleteResidenceRule(TenantId tenantId, ResidenceRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Residence rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }

}
