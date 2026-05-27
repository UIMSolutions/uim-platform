/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.replication_task;
// import uim.platform.hana.application.usecases.manage.replication_tasks;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ReplicationTaskController : ManageController {
  private ManageReplicationTasksUseCase usecase;

  this(ManageReplicationTasksUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/hana/replicationTasks", &handleList);
    router.get("/api/v1/hana/replicationTasks/*", &handleGet);
    router.post("/api/v1/hana/replicationTasks", &handleCreate);
    router.put("/api/v1/hana/replicationTasks/*", &handleUpdate);
    router.delete_("/api/v1/hana/replicationTasks/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      CreateReplicationTaskRequest r;
      r.tenantId = tenantId;
      r.instanceId = j.getString("instanceId");
      r.id = precheck.id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.mode = j.getString("mode");
      r.sourceConnectionId = j.getString("sourceConnectionId");
      r.targetConnectionId = j.getString("targetConnectionId");
      r.scheduleExpression = j.getString("scheduleExpression");
      r.mappings = jsonKeyValuePairs(j, "mappings");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication task created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto tasks = usecase.list(tenantId);

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto t = usecase.getById(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "Replication task not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", t.id)
        .set("instanceId", t.instanceId)
        .set("name", t.name)
        .set("description", t.description)
        .set("mode", t.mode.to!string)
        .set("status", t.status.to!string)
        .set("sourceConnectionId", t.sourceConnectionId)
        .set("targetConnectionId", t.targetConnectionId)
        .set("scheduleExpression", t.scheduleExpression)
        .set("rowsReplicated", t.rowsReplicated)
        .set("errorCount", t.errorCount)
        .set("lastRunAt", t.lastRunAt)
        .set("nextRunAt", t.nextRunAt)
        .set("createdAt", t.createdAt)
        .set("updatedAt", t.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto j = req.json;
      UpdateReplicationTaskRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.mode = j.getString("mode");
      r.scheduleExpression = j.getString("scheduleExpression");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication task updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ReplicationTaskprecheck.id);
      auto result = usecase.deleteReplicationTask(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
