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
import uim.platform.identity_authentication.presentation.http.json_utils;

class EventController {
  private ManageEventsUseCase useCase;

  this(ManageEventsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/events", &handleCreate);
    router.get("/api/v1/events", &handleList);
    router.get("/api/v1/events/*", &handleGet);
    router.put("/api/v1/events/*", &handleUpdate);
    router.delete_("/api/v1/events/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      auto r = CreateEventRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.location = j.getString("location");
      r.meetingUrl = j.getString("meetingUrl");
      r.organizerId = j.getString("organizerId");
      r.organizerName = j.getString("organizerName");
      r.allDay = jsonBool(j, "allDay");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");
      r.timezone = j.getString("timezone");
      r.recurrenceRule = j.getString("recurrenceRule");

      auto result = useCase.createEvent(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto workspaceId = req.params.get("workspaceId", "");
      auto events = useCase.listByWorkspace(workspaceId, tenantId);
      auto arr = Json.emptyArray;
      foreach (ref e; events)
        arr ~= serializeEvent(e);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) events.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto ev = useCase.getEvent(id, tenantId);
      if (ev is null)
      {
        writeError(res, 404, "Event not found");
        return;
      }
      res.writeJsonBody(serializeEvent(*ev), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateEventRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.location = j.getString("location");
      r.meetingUrl = j.getString("meetingUrl");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");

      auto result = useCase.updateEvent(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteEvent(id, tenantId);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }
}
