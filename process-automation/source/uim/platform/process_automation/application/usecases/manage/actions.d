/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.actions;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class ManageActionsUseCase { // TODO: UIMUseCase {
    private ActionRepository repo;

    this(ActionRepository repo) {
        this.repo = repo;
    }

    CommandResult createAction(CreateActionRequest r) {
        if (r.actionId.isEmpty)
            return CommandResult(false, "", "Action ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Action name is required");

        if (repo.existsById(r.tenantId, r.actionId))
            return CommandResult(false, "", "Action already exists");

        Action a;
        a.initEntity(r.tenantId, r.createdBy);

        a.id = r.actionId;
        a.projectId = r.projectId;
        a.name = r.name;
        a.description = r.description;
        a.status = ActionStatus.draft;
        a.baseUrl = r.baseUrl;
        a.path = r.path;
        a.authType = r.authType;
        a.destinationName = r.destinationName;
        a.version_ = r.version_;

        repo.save(a);
        return CommandResult(true, a.id.value, "");
    }

    Action getAction(TenantId tenantId, ActionId id) {
        return repo.findById(tenantId, id);
    }

    Action[] listActions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateAction(UpdateActionRequest r) {
        auto action = repo.findById(r.tenantId, r.actionId);
        if (action.isNull)
            return CommandResult(false, "", "Action not found");

        action.name = r.name;
        action.description = r.description;
        action.baseUrl = r.baseUrl;
        action.path = r.path;
        action.authType = r.authType;
        action.destinationName = r.destinationName;
        action.version_ = r.version_;
        action.updatedBy = r.updatedBy;

        
        action.updatedAt = currentTimestamp;

        repo.update(action);
        return CommandResult(true, action.id.value, "");
    }

    CommandResult deleteAction(TenantId tenantId, ActionId actionId) {
        auto action = repo.findById(tenantId, actionId);
        if (action.isNull)
            return CommandResult(false, "", "Action not found");

        repo.remove(action);
        return CommandResult(true, action.id.value, "");
    }
}
