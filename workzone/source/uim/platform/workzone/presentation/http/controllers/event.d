/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.event;



// import uim.platform.workzone.application.usecases.manage.events;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.event;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class EventController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateEventRequest();
      r.tenantId = tenantId;
      r.workspaceId = data.getString("workspaceId");
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.location = data.getString("location");
      r.meetingUrl = data.getString("meetingUrl");
      r.organizerId = data.getString("organizerId");
      r.organizerName = data.getString("organizerName");
      r.allDay = data.getBoolean("allDay");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");
      r.timezone = data.getString("timezone");
      r.recurrenceRule = data.getString("recurrenceRule");

      auto result = useCase.createEvent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Event created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateEventRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.location = data.getString("location");
      r.meetingUrl = data.getString("meetingUrl");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");

      auto result = useCase.updateEvent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Event updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteEvent(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Event deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
