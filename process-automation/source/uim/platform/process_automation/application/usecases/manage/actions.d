/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.actions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageActionsUseCase : UIMUseCase {
    private ActionRepository repo;

    this(ActionRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateActionRequest r) {
        if (r.id.length == 0)
            return CommandResult(false, "", "Action ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Action name is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Action already exists");

        Action a;
        a.id = r.id;
        a.tenantId = r.tenantId;
        a.projectId = r.projectId;
        a.name = r.name;
        a.description = r.description;
        a.status = ActionStatus.draft;
        a.baseUrl = r.baseUrl;
        a.path = r.path;
        a.authType = r.authType;
        a.destinationName = r.destinationName;
        a.version_ = r.version_;
        a.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        a.createdAt = now;
        a.modifiedAt = now;

        repo.save(a);
        return CommandResult(true, a.id, "");
    }

    Action get_(ActionId id) {
        return repo.findById(id);
    }

    Action[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateActionRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.length == 0)
            return CommandResult(false, "", "Action not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.baseUrl = r.baseUrl;
        existing.path = r.path;
        existing.authType = r.authType;
        existing.destinationName = r.destinationName;
        existing.version_ = r.version_;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ActionId id) {
        auto existing = repo.findById(id);
        if (existing.id.length == 0)
            return CommandResult(false, "", "Action not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
