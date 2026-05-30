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

class TaskController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      auto data = precheck.data;
      CreateTaskRequest r;
      r.tenantId = tenantId;
      r.processInstanceId = data.getString("processInstanceId");
      r.taskId = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.priority = data.getString("priority");
      r.assignee = data.getString("assignee");
      r.candidateUsers = data.getStrings("candidateUsers");
      r.candidateGroups = data.getStrings("candidateGroups");
      r.formId = data.getString("formId");
      r.dueDate = jsonLong(j, "dueDate");

      auto result = taskUsecase.createTask(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask created");

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
        .set("resources", list);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto id = TaskId(precheck.id);
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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto tenantId = precheck.tenantId;

      auto data = precheck.data;
      UpdateTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = TaskId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.priority = data.getString("priority");
      r.assignee = data.getString("assignee");
      r.dueDate = jsonLong(j, "dueDate");

      auto result = taskUsecase.updateTask(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleClaim(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {

      auto tenantId = precheck.tenantId;

      auto path = req.requestURI.to!string;
      auto claimIdx = lastIndexOf(path, "/claim");
      if (claimIdx < 0) {
        writeError(res, 400, "Invalid claim path");
        return;
      }
      auto sub = path[0 .. claimIdx];
      auto id = TaskId(extractIdFromPath(sub));

      auto data = precheck.data;
      ClaimTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = id;
      r.userId = data.getString("userId");

      auto result = taskUsecase.claimTask(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask claimed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      auto completeIdx = lastIndexOf(path, "/complete");
      if (completeIdx < 0) {
        writeError(res, 400, "Invalid complete path");
        return;
      }
      auto sub = path[0 .. completeIdx];
      auto id = TaskId(extractIdFromPath(sub));

      auto data = precheck.data;
      CompleteTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = id;
      r.completedBy = UserId(data.getString("completedBy"));
      r.outcome = data.getString("outcome");
      r.formData = data.getString("formData");

      auto result = taskUsecase.completeTask(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask completed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
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

      auto id = TaskId(precheck.id);
      auto result = taskUsecase.deleteTask(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "PATask deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
