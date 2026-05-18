/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.undelivered_event;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class UndeliveredEventController : PlatformController {
    private ConsumeUndeliveredEventsUseCase usecase;

    this(ConsumeUndeliveredEventsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/alert-notification/undelivered-events",   &handleList);
        router.get("/api/v1/alert-notification/undelivered-events/*", &handleGet);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto result   = usecase.listUndeliveredEvents(tenantId);
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        import std.conv : to;
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto id       = req.requestPath.to!string.pathId;
        auto result   = usecase.getUndeliveredEvent(tenantId, id);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }
}
