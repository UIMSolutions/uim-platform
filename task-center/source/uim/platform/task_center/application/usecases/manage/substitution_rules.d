/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.substitution_rules;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageSubstitutionRulesUseCase { // TODO: UIMUseCase {
    private SubstitutionRuleRepository repo;

    this(SubstitutionRuleRepository repo) {
        this.repo = repo;
    }

    SubstitutionRule getSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        return repo.findById(tenantId, id);
    }

    SubstitutionRule[] listSubstitutionRules(TenantId tenantId, UserId userId) {
        return repo.findByUser(tenantId, userId);
    }

    SubstitutionRule[] listSubstitutionRules(TenantId tenantId, SubstitutionId substituteId) {
        return repo.findBySubstitute(tenantId, substituteId);
    }

    SubstitutionRule[] listSubstitutionRules(TenantId tenantId, SubstitutionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createSubstitutionRule(CreateSubstitutionRuleRequest req) {
        SubstitutionRule r;
        r.tenantId = req.tenantId;
        r.id = req.substitutionRuleId;
        r.userId = req.userId;
        r.substituteId = req.substituteId;
        r.taskDefinitionId = req.taskDefinitionId;
        r.startDate = req.startDate;
        r.endDate = req.endDate;
        r.isAutoForward = req.isAutoForward;
        r.createdBy = req.createdBy;
        repo.save(req.tenantId, r);
        return CommandResult(true, req.substitutionRuleId.value, "");
    }

    CommandResult updateSubstitutionRule(UpdateSubstitutionRuleRequest req) {
        auto existing = repo.findById(req.tenantId, req.substitutionRuleId);
        if (existing == SubstitutionRule.init)
            return CommandResult(false, "", "Substitution rule not found");
        if (req.substituteId.length > 0) existing.substituteId = req.substituteId;
        if (req.taskDefinitionId.length > 0) existing.taskDefinitionId = req.taskDefinitionId;
        if (req.startDate.length > 0) existing.startDate = req.startDate;
        if (req.endDate.length > 0) existing.endDate = req.endDate;
        existing.isAutoForward = req.isAutoForward;
        existing.updatedBy = req.updatedBy;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.substitutionRuleId.value, "");
    }

    CommandResult activateSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        auto r = repo.findById(tenantId, id);
        if (r.isNull)
            return CommandResult(false, "", "Substitution rule not found");
        r.status = SubstitutionStatus.active;
        repo.update(tenantId, r);
        return CommandResult(true, r.id.value, "");
    }

    CommandResult deactivateSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        auto r = repo.findById(tenantId, id);
        if (r.isNull)
            return CommandResult(false, "", "Substitution rule not found");
        r.status = SubstitutionStatus.inactive;
        repo.update(tenantId, r);
        return CommandResult(true, r.id.value, "");
    }

    CommandResult deleteSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Substitution rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }
}
