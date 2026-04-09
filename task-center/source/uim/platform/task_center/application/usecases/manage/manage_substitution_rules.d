/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.substitution_rules;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageSubstitutionRulesUseCase : UIMUseCase {
    private SubstitutionRuleRepository repo;

    this(SubstitutionRuleRepository repo) {
        this.repo = repo;
    }

    SubstitutionRule get_(string tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    SubstitutionRule[] listByUser(string tenantId, string userId) {
        return repo.findByUser(tenantId, userId);
    }

    SubstitutionRule[] listBySubstitute(string tenantId, string substituteId) {
        return repo.findBySubstitute(tenantId, substituteId);
    }

    SubstitutionRule[] listByStatus(string tenantId, SubstitutionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult create(CreateSubstitutionRuleRequest req) {
        SubstitutionRule r;
        r.id = req.id;
        r.tenantId = req.tenantId;
        r.userId = req.userId;
        r.substituteId = req.substituteId;
        r.taskDefinitionId = req.taskDefinitionId;
        r.startDate = req.startDate;
        r.endDate = req.endDate;
        r.isAutoForward = req.isAutoForward;
        r.createdBy = req.createdBy;
        repo.save(req.tenantId, r);
        return CommandResult(true, req.id, "");
    }

    CommandResult update(UpdateSubstitutionRuleRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing == SubstitutionRule.init)
            return CommandResult(false, "", "Substitution rule not found");
        if (req.substituteId.length > 0) existing.substituteId = req.substituteId;
        if (req.taskDefinitionId.length > 0) existing.taskDefinitionId = req.taskDefinitionId;
        if (req.startDate.length > 0) existing.startDate = req.startDate;
        if (req.endDate.length > 0) existing.endDate = req.endDate;
        existing.isAutoForward = req.isAutoForward;
        existing.modifiedBy = req.modifiedBy;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.id, "");
    }

    CommandResult activate(string tenantId, string id) {
        auto r = repo.findById(tenantId, id);
        if (r == SubstitutionRule.init)
            return CommandResult(false, "", "Substitution rule not found");
        r.status = SubstitutionStatus.active;
        repo.update(tenantId, r);
        return CommandResult(true, id.toString, "");
    }

    CommandResult deactivate(string tenantId, string id) {
        auto r = repo.findById(tenantId, id);
        if (r == SubstitutionRule.init)
            return CommandResult(false, "", "Substitution rule not found");
        r.status = SubstitutionStatus.inactive;
        repo.update(tenantId, r);
        return CommandResult(true, id.toString, "");
    }

    CommandResult remove(string tenantId, string id) {
        repo.remove(tenantId, id);
        return CommandResult(true, id.toString, "");
    }
}
