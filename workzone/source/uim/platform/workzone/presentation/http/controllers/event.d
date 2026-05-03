/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.event;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.events;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.event;

class EventController : PlatformController {
  private ManageEventsUseCase useCase;

  this(ManageEventsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/events", &handleCreate);
    router.get("/api/v1/events", &handleList);
    router.get("/api/v1/events/*", &handleGet);
    router.put("/api/v1/events/*", &handleUpdate);
    router.delete_("/api/v1/events/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateEventRequest();
      r.tenantId = req.getTenantId;
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.location = j.getString("location");
      r.meetingUrl = j.getString("meetingUrl");
      r.organizerId = j.getString("organizerId");
      r.organizerName = j.getString("organizerName");
      r.allDay = j.getBoolean("allDay");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");
      r.timezone = j.getString("timezone");
      r.recurrenceRule = j.getString("recurrenceRule");

      auto result = useCase.createEvent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Event created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto workspaceId = req.params.get("workspaceId", "");

      auto events = useCase.listByWorkspace(tenantId, workspaceId);
      auto arr = events.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", events.length)
        .set("message", "Events retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto ev = useCase.getEvent(tenantId, id);
      if (ev.isNull) {
        writeError(res, 404, "Event not found");
        return;
      }
      res.writeJsonBody(ev.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateEventRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.location = j.getString("location");
      r.meetingUrl = j.getString("meetingUrl");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");

      auto result = useCase.updateEvent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Event updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteEvent(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Event deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
