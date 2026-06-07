/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.usecases.manage.actions;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

class ManageActionsUseCase {
    private ActionRepository repo;

    this(ActionRepository repo) { this.repo = repo; }

    CommandResult createAction(TenantId tenantId, CreateActionRequest req) {
        auto existing = repo.findByName(tenantId, req.name);
        if (existing !is null && !existing.isNull())
            return CommandResult(false, "", "Action '" ~ req.name ~ "' already exists");

        auto action = new Action(tenantId);
        action.name        = req.name;
        action.description = req.description;
        action.type_       = req.type_.to!ActionType;
        action.state       = req.state.length ? req.state.to!ResourceState : ResourceState.enabled;
        action.properties  = req.properties.dup;
        action.labels      = req.labels.dup;
        action.fallbackAction       = req.fallbackAction;
        action.enableDeliveryStatus = req.enableDeliveryStatus;

        repo.save(action);
        return CommandResult(true, action.id.toString(), action.toJson().toString());
    }

    QueryResult getAction(TenantId tenantId, ActionId id) {
        auto action = repo.findById(tenantId, id);
        if (action is null || action.isNull())
            return QueryResult(false, "Action not found", Json.emptyObject);
        return QueryResult(true, "", action.toJson());
    }

    QueryResult listActions(TenantId tenantId) {
        auto items = repo.findByTenant(tenantId);
        auto arr   = items.map!(a => a.toJson).array.toJson;

        return QueryResult(true, "", arr);
    }

    CommandResult updateAction(TenantId tenantId, ActionId id, UpdateActionRequest req) {
        auto action = repo.findById(tenantId, id);
        if (action is null || action.isNull())
            return CommandResult(false, "", "Action not found");

        if (req.description.length) action.description = req.description;
        if (req.state.length)       action.state = req.state.to!ResourceState;
        if (req.properties.length)  action.properties = req.properties.dup;
        if (req.labels.length)      action.labels = req.labels.dup;
        if (req.fallbackAction.length) action.fallbackAction = req.fallbackAction;
        action.enableDeliveryStatus = req.enableDeliveryStatus;

        repo.save(action);
        return CommandResult(true, action.id.toString(), action.toJson().toString());
    }

    CommandResult deleteAction(TenantId tenantId, ActionId id) {
        auto action = repo.findById(tenantId, id);
        if (action is null || action.isNull())
            return CommandResult(false, "", "Action not found");

        repo.remove(action);
        return CommandResult(true, action.id.toString(), "Action deleted");
    }
}
