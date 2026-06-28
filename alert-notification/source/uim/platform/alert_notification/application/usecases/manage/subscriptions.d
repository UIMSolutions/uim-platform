/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.usecases.manage.subscriptions;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

class ManageSubscriptionsUseCase {
    private SubscriptionRepository repo;

    this(SubscriptionRepository repo) { this.repo = repo; }

    CommandResult createSubscription(TenantId tenantId, CreateSubscriptionRequest req) {
        if (repo.existsByName(tenantId, req.name))
            return CommandResult(false, "", "Subscription '" ~ req.name ~ "' already exists");

        auto sub = Subscription(tenantId);
        sub.name        = req.name;
        sub.description = req.description;
        sub.conditions  = req.conditions.dup;
        sub.actions     = req.actions.dup;
        sub.state       = req.state.length ? req.state.to!ResourceState : ResourceState.enabled;
        sub.labels      = req.labels.dup;

        repo.save(sub);
        return CommandResult(true, sub.id.value, sub.toJson().toString());
    }

    QueryResult getSubscription(TenantId tenantId, string id) {
        auto sub = repo.findById(tenantId, SubscriptionId(id));
        if (sub is null || sub.isNull())
            return QueryResult(false, "Subscription not found", Json.emptyObject);
        return QueryResult(true, "", sub.toJson());
    }

    QueryResult listSubscriptions(TenantId tenantId) {
        auto items = repo.find(tenantId);
        auto arr   = Json.emptyArray;
        foreach (s; items) arr ~= s.toJson();
        return QueryResult(true, "", arr);
    }

    CommandResult updateSubscription(TenantId tenantId, SubscriptionId id, UpdateSubscriptionRequest req) {
        auto sub = repo.find(tenantId, id);
        if (sub is null || sub.isNull())
            return CommandResult(false, "", "Subscription not found");

        if (req.description.length) sub.description = req.description;
        if (req.conditions.length)  sub.conditions  = req.conditions.dup;
        if (req.actions.length)     sub.actions     = req.actions.dup;
        if (req.state.length)       sub.state       = req.state.to!ResourceState;
        if (req.labels.length)      sub.labels      = req.labels.dup;

        repo.save(sub);
        return CommandResult(true, sub.id.value, sub.toJson().toString());
    }

    CommandResult deleteSubscription(TenantId tenantId, SubscriptionId id) {
        auto sub = repo.find(tenantId, id);
        if (sub is null || sub.isNull())
            return CommandResult(false, "", "Subscription not found");

        repo.removeB(sub);
        return CommandResult(true, sub.id.value, "Subscription deleted");
    }
}
