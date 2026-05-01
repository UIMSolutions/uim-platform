/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.actions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageActionsUseCase { // TODO: UIMUseCase {
    private ActionRepository repo;

    this(ActionRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateActionRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "Action ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Action name is required");

        if (repo.existsById(r.id))
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
        a.updatedAt = now;

        repo.save(a);
        return CommandResult(true, a.id, "");
    }

    Action getById(ActionId id) {
        return repo.findById(id);
    }

    Action[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateActionRequest r) {
        if (!repo.existsById(r.id))
            return CommandResult(false, "", "Action not found");

        auto existing = repo.findById(r.id);
        existing.name = r.name;
        existing.description = r.description;
        existing.baseUrl = r.baseUrl;
        existing.path = r.path;
        existing.authType = r.authType;
        existing.destinationName = r.destinationName;
        existing.version_ = r.version_;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ActionId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Action not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
