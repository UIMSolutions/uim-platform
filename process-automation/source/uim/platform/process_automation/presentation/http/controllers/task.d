/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.task;

// import uim.platform.process_automation.application.taskss.manage.tasks;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class TaskController : PlatformController {
  private ManageTasksUseCase taskUsecase;

  this(ManageTasksUseCase taskUsecase) {
    this.taskUsecase = taskUsecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/process-automation/tasks", &handleList);
    router.get("/api/v1/process-automation/tasks/*", &handleGet);
    router.post("/api/v1/process-automation/tasks", &handleCreate);
    router.put("/api/v1/process-automation/tasks/*", &handleUpdate);
    router.post("/api/v1/process-automation/tasks/*/claim", &handleClaim);
    router.post("/api/v1/process-automation/tasks/*/complete", &handleComplete);
    router.delete_("/api/v1/process-automation/tasks/*", &handleDelete);
  }

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      CreateTaskRequest r;
      r.tenantId = tenantId;
      r.processInstanceId = j.getString("processInstanceId");
      r.taskId = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.priority = j.getString("priority");
      r.assignee = j.getString("assignee");
      r.candidateUsers = getStrings(j, "candidateUsers");
      r.candidateGroups = getStrings(j, "candidateGroups");
      r.formId = j.getString("formId");
      r.dueDate = jsonLong(j, "dueDate");

      auto result = taskUsecase.createTask(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto results = taskUsecase.listTasks(tenantId);

      auto jarr = Json.emptyArray;
      foreach (t; results) {
        jarr ~= Json.emptyObject
          .set("id", t.id)
          .set("name", t.name)
          .set("type", t.type.to!string)
          .set("status", t.status.to!string)
          .set("priority", t.priority.to!string)
          .set("assignee", t.assignee)
          .set("processInstanceId", t.processInstanceId)
          .set("createdAt", t.createdAt)
          .set("dueDate", t.dueDate);
      }

      auto resp = Json.emptyObject
        .set("count", results.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto id = TaskId(extractIdFromPath(req.requestURI.to!string));
      auto t = taskUsecase.getTask(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "PATask not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", t.id)
        .set("name", t.name)
        .set("description", t.description)
        .set("type", t.type.to!string)
        .set("status", t.status.to!string)
        .set("priority", t.priority.to!string)
        .set("assignee", t.assignee)
        .set("processInstanceId", t.processInstanceId)
        .set("formId", t.formId)
        .set("formData", t.formData)
        .set("candidateUsers", t.candidateUsers.map!(u => Json(u.value)).array.toJson)
        .set("candidateGroups", t.candidateGroups.map!(g => Json(g)).array.toJson)
        .set("completedBy", t.completedBy)
        .set("outcome", t.outcome)
        .set("createdAt", t.createdAt)
        .set("dueDate", t.dueDate)
        .set("completedAt", t.completedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {

      auto tenantId = req.getTenantId;

      auto j = req.json;
      UpdateTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = TaskId(extractIdFromPath(req.requestURI.to!string));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.priority = j.getString("priority");
      r.assignee = j.getString("assignee");
      r.dueDate = jsonLong(j, "dueDate");

      auto result = taskUsecase.updateTask(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetClaim(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {

      auto tenantId = req.getTenantId;

      auto path = req.requestURI.to!string;
      auto claimIdx = lastIndexOf(path, "/claim");
      if (claimIdx < 0) {
        writeError(res, 400, "Invalid claim path");
        return;
      }
      auto sub = path[0 .. claimIdx];
      auto id = TaskId(extractIdFromPath(sub));

      auto j = req.json;
      ClaimTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = id;
      r.userId = j.getString("userId");

      auto result = taskUsecase.claimTask(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask claimed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetComplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      auto completeIdx = lastIndexOf(path, "/complete");
      if (completeIdx < 0) {
        writeError(res, 400, "Invalid complete path");
        return;
      }
      auto sub = path[0 .. completeIdx];
      auto id = TaskId(extractIdFromPath(sub));

      auto j = req.json;
      CompleteTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = id;
      r.completedBy = UserId(j.getString("completedBy"));
      r.outcome = j.getString("outcome");
      r.formData = j.getString("formData");

      auto result = taskUsecase.completeTask(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask completed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto id = TaskId(extractIdFromPath(req.requestURI.to!string));
      auto result = taskUsecase.deleteTask(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
