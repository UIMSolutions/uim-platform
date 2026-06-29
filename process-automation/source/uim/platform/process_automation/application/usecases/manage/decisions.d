/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.decisions;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class ManageDecisionsUseCase { // TODO: UIMUseCase {
    private DecisionRepository repo;

    this(DecisionRepository repo) {
        this.repo = repo;
    }

    CommandResult createDecision(CreateDecisionRequest r) {
        if (r.decisionId.isEmpty)
            return CommandResult(false, "", "Decision ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Decision name is required");

        auto existing = repo.find(r.tenantId, r.decisionId);
        if (!existing.isNull)
            return CommandResult(false, "", "Decision already exists");

        Decision d;
        d.initEntity(r.tenantId, r.createdBy);
        d.id = r.decisionId;
        d.projectId = r.projectId;
        d.name = r.name;
        d.description = r.description;
        d.status = DecisionStatus.draft;
        d.version_ = r.version_;
        d.updatedAt = d.createdAt;

        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    Decision getDecision(TenantId tenantId, DecisionId id) {
        return repo.findById(tenantId, id);
    }

    Decision[] listDecisions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateDecision(UpdateDecisionRequest r) {
        auto decision = repo.find(r.tenantId, r.decisionId);
        if (decision.isNull)
            return CommandResult(false, "", "Decision not found");

        decision.name = r.name;
        decision.description = r.description;
        decision.version_ = r.version_;
        decision.updatedBy = r.updatedBy;

        
        decision.updatedAt = currentTimestamp;

        repo.update(decision);
        return CommandResult(true, decision.id.value, "");
    }

    CommandResult deleteDecision(TenantId tenantId, DecisionId id) {
        auto decision = repo.findById(tenantId, id);
        if (decision.isNull)
            return CommandResult(false, "", "Decision not found");

        repo.remove(decision);
        return CommandResult(true, decision.id.value, "");
    }
}
