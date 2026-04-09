/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.decisions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageDecisionsUseCase : UIMUseCase {
    private DecisionRepository repo;

    this(DecisionRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDecisionRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "Decision ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Decision name is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Decision already exists");

        Decision d;
        d.id = r.id;
        d.tenantId = r.tenantId;
        d.projectId = r.projectId;
        d.name = r.name;
        d.description = r.description;
        d.status = DecisionStatus.draft;
        d.version_ = r.version_;
        d.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        d.createdAt = now;
        d.modifiedAt = now;

        repo.save(d);
        return CommandResult(true, d.id, "");
    }

    Decision get_(DecisionId id) {
        return repo.findById(id);
    }

    Decision[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateDecisionRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Decision not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.version_ = r.version_;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(DecisionId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Decision not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
