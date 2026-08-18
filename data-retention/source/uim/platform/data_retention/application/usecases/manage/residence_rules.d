/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageResidenceRulesUseCase {
    private IResidenceRuleRepository repo;

    this(IResidenceRuleRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createResidenceRule(CreateResidenceRuleRequest req) {
        import std.uuid : randomUUID;

        if (req.duration <= 0)
            return UsecaseResult(false, "", "Duration must be positive");

        auto rr = ResidenceRule(req.tenantId);
        rr.businessPurposeId = req.purposeId;
        rr.legalGroundId = req.groundId;
        rr.duration = req.duration;
        rr.periodUnit = req.periodUnit.toPeriodUnit;
        rr.isActive = true;

        repo.save(rr);
        return UsecaseResult(true, rr.id.value, "");
    }

    UsecaseResult updateResidenceRule(UpdateResidenceRuleRequest req) {
        auto rule = repo.findById(req.tenantId, req.ruleId);
        if (rule.isNull)
            return UsecaseResult(false, "", "Residence rule not found");

        if (req.duration > 0)
            rule.duration = req.duration;

        if (req.periodUnit.length > 0)
            rule.periodUnit = req.periodUnit.toPeriodUnit;

        rule.isActive = req.isActive;
        rule.updatedAt = clockSeconds();

        repo.update(rule);
        return UsecaseResult(true, rule.id.value, "");
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

    UsecaseResult deleteResidenceRule(TenantId tenantId, ResidenceRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return UsecaseResult(false, "", "Residence rule not found");

        repo.remove(rule);
        return UsecaseResult(true, rule.id.value, "");
    }

}
