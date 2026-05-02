/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.event;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.query_platform_events;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EventController : PlatformController {
  private QueryPlatformEventsUseCase uc;

  this(QueryPlatformEventsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/events", &handleList);
    router.get("/api/v1/events/*", &handleGet);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto gaId = req.params.get("globalAccountId");
      auto subId = req.params.get("subaccountId");
      auto category = req.params.get("category");
      auto severity = req.params.get("severity");

      PlatformEvent[] items;
      if (subId.length > 0)
        items = uc.listBySubaccount(subId);
      else if (category.length > 0 && gaId.length > 0)
        items = uc.listByCategory(gaId, category);
      else if (severity.length > 0 && gaId.length > 0)
        items = uc.listBySeverity(gaId, severity);
      else if (gaId.length > 0)
        items = uc.listByGlobalAccount(gaId);

      auto arr = items.map!(ev => ev.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto ev = uc.getById(id);
      if (ev.isNull) {
        writeError(res, 404, "Event not found");
        return;
      }
      res.writeJsonBody(ev.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeEvent(PlatformEvent event) {
  return Json.emptyObject
    .set("id", event.id)
    .set("globalAccountId", event.globalAccountId)
    .set("subaccountId", event.subaccountId)
    .set("directoryId", event.directoryId)
    .set("category", to!string(event.category))
    .set("severity", to!string(event.severity))
    .set("eventType", event.eventType)
    .set("description", event.description)
    .set("resourceId", event.resourceId)
    .set("resourceType", event.resourceType)
    .set("initiatedBy", event.initiatedBy)
    .set("sourceService", event.sourceService)
    .set("timestamp", event.timestamp)
    .set("details", event.details);
}

