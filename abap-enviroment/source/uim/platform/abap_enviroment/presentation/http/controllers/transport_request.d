/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.presentation.http.transport_request;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.abap_enviroment.application.usecases.manage.transport_requests;
import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.transport_request;
import uim.platform.abap_enviroment.domain.types;

class TransportRequestController : PlatformController {
  private ManageTransportRequestsUseCase uc;

  this(ManageTransportRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/transports", &handleCreate);
    router.get("/api/v1/transports", &handleList);
    router.get("/api/v1/transports/*", &handleGetById);
    router.post("/api/v1/transports/tasks/*", &handleAddTask);
    router.post("/api/v1/transports/release/*", &handleRelease);
    router.post("/api/v1/transports/release-task/*", &handleReleaseTask);
    router.delete_("/api/v1/transports/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTransportRequestRequest r;
      r.tenantId = req.getTenantId;
      r.sourceSystemId = j.getString("sourceSystemId");
      r.targetSystemId = j.getString("targetSystemId");
      r.description = j.getString("description");
      r.owner = j.getString("owner");
      r.transportType = j.getString("transportType");

      auto result = uc.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      auto systemId = req.headers.get("X-System-Id", "");
      auto requests = uc.listRequests(systemId);
      auto arr = Json.emptyArray;
      foreach (tr; requests)
        arr ~= serializeRequest(tr);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(requests.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tr = uc.getRequest(id);
      if (tr is null) {
        writeError(res, 404, "Transport request not found");
        return;
      }
      res.writeJsonBody(serializeRequest(*tr), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAddTask(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto requestId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      AddTransportTaskRequest r;
      r.owner = j.getString("owner");
      r.description = j.getString("description");
      r.objectList = jsonStrArray(j, "objectList");

      auto result = uc.addTask(requestId, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["taskId"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.releaseRequest(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("released");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleReleaseTask(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto requestId = j.getString("requestId");
      auto taskId = extractIdFromPath(req.requestURI);

      auto result = uc.releaseTask(requestId, taskId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("released");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteRequest(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("deleted");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRequest(const TransportRequest tr) {
    auto j = Json.emptyObject
      .set("id", tr.id)
      .set("tenantId", tr.tenantId)
      .set("sourceSystemId", tr.sourceSystemId)
      .set("targetSystemId", tr.targetSystemId)
      .set("description", tr.description)
      .set("owner", tr.owner)
      .set("transportType", tr.transportType.to!string)
      .set("status", tr.status.to!string)
      .set("createdAt", tr.createdAt)
      .set("releasedAt", tr.releasedAt)
      .set("importedAt", tr.importedAt);

    if (tr.tasks.length > 0) {
      auto tasks = Json.emptyArray;
      foreach (t; tr.tasks) {
        auto tj = Json.emptyObject;
        
        .set("taskId", t.taskId)
          .set("owner", t.owner)
          .set("status", t.status.to!string)
          .set("description", t.description)
          .set("createdAt", t.createdAt)
          .set("releasedAt", t.releasedAt);

        if (t.objectList.length > 0) {
          auto ol = Json.emptyArray;
          foreach (o; t.objectList)
            ol ~= Json(o);
          tj["objectList"] = ol;
        }

        tasks ~= tj;
      }
      j["tasks"] = tasks;
    }

    return j;
  }
}
