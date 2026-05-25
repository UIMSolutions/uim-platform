/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.event;


// 
// import uim.platform.management.application.usecases.query_platform_events;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EventController : PlatformController {
  private QueryPlatformEventsUseCase usecase;

  this(QueryPlatformEventsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/events", &handleList);
    router.get("/api/v1/events/*", &handleGet);
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto gaId = req.params.get("globalAccountId");
      auto subId = req.params.get("subaccountId");
      auto category = req.params.get("category");
      auto severity = req.params.get("severity");

      PlatformEvent[] items;
      if (!subId.isEmpty)
        items = usecase.listEvents(tenantId, subId);
      else if (!category.isEmpty && !gaId.isEmpty)
        items = usecase.listEvents(tenantId, gaId, category);
      else if (!severity.isEmpty && !gaId.isEmpty)
        items = usecase.listEvents(tenantId, gaId, severity);
      else if (!gaId.isEmpty)
        items = usecase.listEvents(tenantId, gaId);

      auto arr = items.map!(ev => ev.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Events retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto ev = usecase.getEvent(tenantId, id);
      if (ev.isNull) {
        writeError(res, 404, "Event not found");
        return;
      }
      res.writeJsonBody(ev.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}


