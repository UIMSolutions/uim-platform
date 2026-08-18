/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.decisions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageDecisionsUseCase {
    private IDecisionRepository repo;

    this(IDecisionRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createDecision(CreateDecisionRequest r) {
        if (r.decisionId.isEmpty)
            return UsecaseResult(false, "", "Decision ID is required");
        if (r.name.isEmpty)
            return UsecaseResult(false, "", "Decision name is required");

        auto existing = repo.findById(r.tenantId, r.decisionId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Decision already exists");

        auto d = Decision(r.tenantId); //, UserId("test-user"));
        d.id = r.decisionId;
        d.projectId = r.projectId;
        d.name = r.name;
        d.description = r.description;
        d.status = DecisionStatus.draft;
        d.version_ = r.version_;
        d.updatedAt = d.createdAt;

        repo.save(d);
        return UsecaseResult(true, d.id.value, "");
    }

    Decision getDecision(TenantId tenantId, DecisionId id) {
        return repo.findById(tenantId, id);
    }

    Decision[] listDecisions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateDecision(UpdateDecisionRequest r) {
        auto decision = repo.findById(r.tenantId, r.decisionId);
        if (decision.isNull)
            return UsecaseResult(false, "", "Decision not found");

        decision.name = r.name;
        decision.description = r.description;
        decision.version_ = r.version_;
        decision.updatedBy = r.updatedBy;

        
        decision.updatedAt = currentTimestamp;

        repo.update(decision);
        return UsecaseResult(true, decision.id.value, "");
    }

    UsecaseResult deleteDecision(TenantId tenantId, DecisionId id) {
        auto decision = repo.findById(tenantId, id);
        if (decision.isNull)
            return UsecaseResult(false, "", "Decision not found");

        repo.remove(decision);
        return UsecaseResult(true, decision.id.value, "");
    }
}
