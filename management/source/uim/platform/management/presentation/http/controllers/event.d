module uim.platform.management.presentation.http.controllers.event;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.query_platform_events;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.types;
// import presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EventController {
    private QueryPlatformEventsUseCase uc;

    this(QueryPlatformEventsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
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

            auto arr = Json.emptyArray;
            foreach (ref ev; items)
                arr ~= serializeEvent(ev);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)items.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto ev = uc.getById(id);
            if (ev.id.length == 0) {
                writeError(res, 404, "Event not found");
                return;
            }
            res.writeJsonBody(serializeEvent(ev), 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }
}

private Json serializeEvent(ref PlatformEvent ev) {
    auto j = Json.emptyObject;
    j["id"] = Json(ev.id);
    j["globalAccountId"] = Json(ev.globalAccountId);
    j["subaccountId"] = Json(ev.subaccountId);
    j["directoryId"] = Json(ev.directoryId);
    j["category"] = Json(enumStr(ev.category));
    j["severity"] = Json(enumStr(ev.severity));
    j["eventType"] = Json(ev.eventType);
    j["description"] = Json(ev.description);
    j["resourceId"] = Json(ev.resourceId);
    j["resourceType"] = Json(ev.resourceType);
    j["initiatedBy"] = Json(ev.initiatedBy);
    j["sourceService"] = Json(ev.sourceService);
    j["timestamp"] = Json(ev.timestamp);
    j["details"] = serializeStrMap(ev.details);
    return j;
}

private string enumStr(E)(E val) {
    import std.conv : to;

    return val.to!string;
}
