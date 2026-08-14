/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.undelivered_event;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class UndeliveredEventController : HttpController {
    private ConsumeUndeliveredEventsUseCase usecase;

    this(ConsumeUndeliveredEventsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/alert-notification/undelivered-events",   &handleList);
        router.get("/api/v1/alert-notification/undelivered-events/*", &handleGet);
    }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result   = usecase.listUndeliveredEvents(tenantId);
    res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id       = req.requestPath.to!string.split("/")[$-1];
        auto result   = usecase.getUndeliveredEvent(tenantId, id);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }
}
