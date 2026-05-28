/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.usecases.consume.undelivered_events;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class ConsumeUndeliveredEventsUseCase {
    private UndeliveredEventRepository repo;

    this(UndeliveredEventRepository repo) { this.repo = repo; }

    QueryResult listUndeliveredEvents(TenantId tenantId) {
        auto items = repo.findAll(tenantId);
        auto arr   = Json.emptyArray;
        foreach (e; items) arr ~= e.toJson();
        return QueryResult(true, "", arr);
    }

    QueryResult getUndeliveredEvent(TenantId tenantId, string id) {
        auto ev = repo.findById(tenantId, UndeliveredEventId(id));
        if (ev is null || ev.isNull())
            return QueryResult(false, "Undelivered event not found", Json.emptyObject);
        return QueryResult(true, "", ev.toJson());
    }
}
