/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.replication_task;

// import uim.platform.hana.application.usecases.manage.replication_tasks;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ReplicationTaskController : PlatformController {
  private ManageReplicationTasksUseCase uc;

  this(ManageReplicationTasksUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/replicationTasks", &handleList);
    router.get("/api/v1/hana/replicationTasks/*", &handleGet);
    router.post("/api/v1/hana/replicationTasks", &handleCreate);
    router.put("/api/v1/hana/replicationTasks/*", &handleUpdate);
    router.delete_("/api/v1/hana/replicationTasks/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateReplicationTaskRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.mode = j.getString("mode");
      r.sourceConnectionId = j.getString("sourceConnectionId");
      r.targetConnectionId = j.getString("targetConnectionId");
      r.scheduleExpression = j.getString("scheduleExpression");
      r.mappings = jsonKeyValuePairs(j, "mappings");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Replication task created");
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
      auto tasks = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (t; tasks) {
        jarr ~= Json.emptyObject
          .set("id", t.id)
          .set("instanceId", t.instanceId)
          .set("name", t.name)
          .set("mode", t.mode.to!string)
          .set("status", t.status.to!string)
          .set("rowsReplicated", t.rowsReplicated)
          .set("createdAt", t.createdAt);
      }

      auto response = Json.emptyObject;
      response["count"] = Json(tasks.length);
      response["resources"] = jarr;

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto t = uc.getById(id);
      if (t.id.isEmpty) {
        writeError(res, 404, "Replication task not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(t.id);
      resp["instanceId"] = Json(t.instanceId);
      resp["name"] = Json(t.name);
      resp["description"] = Json(t.description);
      resp["mode"] = Json(t.mode.to!string);
      resp["status"] = Json(t.status.to!string);
      resp["sourceConnectionId"] = Json(t.sourceConnectionId);
      resp["targetConnectionId"] = Json(t.targetConnectionId);
      resp["scheduleExpression"] = Json(t.scheduleExpression);
      resp["rowsReplicated"] = Json(t.rowsReplicated);
      resp["errorCount"] = Json(t.errorCount);
      resp["lastRunAt"] = Json(t.lastRunAt);
      resp["nextRunAt"] = Json(t.nextRunAt);
      resp["createdAt"] = Json(t.createdAt);
      resp["modifiedAt"] = Json(t.modifiedAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateReplicationTaskRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.mode = j.getString("mode");
      r.scheduleExpression = j.getString("scheduleExpression");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Replication task updated");
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
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
