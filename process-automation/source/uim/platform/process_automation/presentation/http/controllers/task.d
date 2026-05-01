/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.task;

import uim.platform.process_automation.application.usecases.manage.tasks;
import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

class TaskController : PlatformController {
  private ManageTasksUseCase uc;

  this(ManageTasksUseCase uc) {
    this.uc = uc;
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTaskRequest r;
      r.tenantId = req.getTenantId;
      r.processInstanceId = j.getString("processInstanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.priority = j.getString("priority");
      r.assignee = j.getString("assignee");
      r.candidateUsers = getStringArray(j, "candidateUsers");
      r.candidateGroups = getStringArray(j, "candidateGroups");
      r.formId = j.getString("formId");
      r.dueDate = jsonLong(j, "dueDate");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task created");
        
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
          .set("count", tasks.length)
          .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto t = uc.getById(id);
      if (t.isNull) {
        writeError(res, 404, "Task not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", t.id)
        .set("name", t.name)
        .set("description", t.description)
        .set("type", t.type.t!string))
        .set("status", t.status.t!string))
        .set("priority", t.priority.t!string))
        .set("assignee", t.assignee)
        .set("processInstanceId", t.processInstanceId)
        .set("formId", t.formId)
        .set("formData", t.formData)
        .set("candidateUsers", t.candidateUsers)
        .set("candidateGroups", t.candidateGroups)
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

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateTaskRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.priority = j.getString("priority");
      r.assignee = j.getString("assignee");
      r.dueDate = jsonLong(j, "dueDate");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleClaim(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      auto claimIdx = lastIndexOf(path, "/claim");
      if (claimIdx < 0) {
        writeError(res, 400, "Invalid claim path");
        return;
      }
      auto sub = path[0 .. claimIdx];
      auto id = extractIdFromPath(sub);

      auto j = req.json;
      ClaimTaskRequest r;
      r.tenantId = req.getTenantId;
      r.id = id;
      r.userId = j.getString("userId");

      auto result = uc.claim(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task claimed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      auto completeIdx = lastIndexOf(path, "/complete");
      if (completeIdx < 0) {
        writeError(res, 400, "Invalid complete path");
        return;
      }
      auto sub = path[0 .. completeIdx];
      auto id = extractIdFromPath(sub);

      auto j = req.json;
      CompleteTaskRequest r;
      r.tenantId = req.getTenantId;
      r.id = id;
      r.completedBy = j.getString("completedBy");
      r.outcome = j.getString("outcome");
      r.formData = j.getString("formData");

      auto result = uc.complete(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task completed");
            
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
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.removeById(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Task deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
