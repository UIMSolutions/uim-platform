/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.event;

// 
// import uim.platform.management.application.usecases.query_platform_events;
// import uim.platform.management.domain.entities.platform_event;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class EventController : ManageHttpController {
  private QueryEnvironmentEventsUseCase usecase;

  this(QueryEnvironmentEventsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/events", &handleList);
    router.get("/api/v1/events/*", &handleGet);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto gaId = GlobalAccountId(req.params.get("globalAccountId"));
    auto subId = SubaccountId(req.params.get("subaccountId"));
    auto category = req.params.get("category");
    auto severity = req.params.get("severity");

    EnvironmentEvent[] items;
    if (!subId.isEmpty)
      items = usecase.listEvents(tenantId, subId);
    else if (!category.isEmpty && !gaId.isEmpty)
      items = usecase.listEvents(tenantId, gaId, category.toEnvironmentEventCategory);
    else if (!severity.isEmpty && !gaId.isEmpty)
      items = usecase.listEvents(tenantId, gaId, severity.toEnvironmentEventSeverity);
    else if (!gaId.isEmpty)
      items = usecase.listEvents(tenantId, gaId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Event list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = EnvironmentEventId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid event ID", 400);

    auto ev = usecase.getEvent(tenantId, id);
    if (ev.isNull)
      return errorResponse("Event not found", 404);

    auto responseData = ev.toJson();
    return successResponse("Event retrieved successfully", "Retrieved", 200, responseData);
  }
}
