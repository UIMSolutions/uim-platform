/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.task;



// import uim.platform.workzone.application.usecases.manage.tasks;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.task;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class TaskController : ManageController {
  private ManageTasksUseCase useCase;

  this(ManageTasksUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/tasks", &handleCreate);
    router.get("/api/v1/tasks", &handleList);
    router.get("/api/v1/tasks/*", &handleGet);
    router.put("/api/v1/tasks/*", &handleUpdate);
    router.post("/api/v1/tasks/complete/*", &handleComplete);
    router.delete_("/api/v1/tasks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateTaskRequest();
      r.tenantId = tenantId;
      r.assigneeId = data.getString("assigneeId");
      r.assigneeName = data.getString("assigneeName");
      r.creatorId = data.getString("creatorId");
      r.creatorName = data.getString("creatorName");
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.sourceApp = data.getString("sourceApp");
      r.sourceTaskId = data.getString("sourceTaskId");
      r.actionUrl = data.getString("actionUrl");
      r.category = data.getString("category");
      r.tags = data.getStrings("tags");
      r.dueDate = jsonLong(j, "dueDate");

      auto pStr = data.getString("priority");
      if (pStr == "low")
        r.priority = TaskPriority.low;
      else if (pStr == "high")
        r.priority = TaskPriority.high;
      else if (pStr == "veryHigh")
        r.priority = TaskPriority.veryHigh;
      else
        r.priority = TaskPriority.medium;

      auto result = useCase.createTask(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "WZTask created");

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
      auto assigneeId = AssigneeId(req.params.get("assigneeId", ""));
      auto tasks = useCase.listByAssignee(tenantId, assigneeId);
      auto arr = tasks.map!(t => t.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(tasks.length))
        .set("message", "Tasks retrieved successfully");

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
      auto t = useCase.getTask(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "WZTask not found");
        return;
      }
      res.writeJsonBody(t.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = UpdateTaskRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.dueDate = jsonLong(j, "dueDate");

      auto sStr = data.getString("status");
      if (sStr == "inProgress")
        r.status = TaskStatus.inProgress;
      else if (sStr == "completed")
        r.status = TaskStatus.completed;
      else if (sStr == "cancelled")
        r.status = TaskStatus.cancelled;
      else
        r.status = TaskStatus.open;

      auto pStr = data.getString("priority");
      if (pStr == "low")
        r.priority = TaskPriority.low;
      else if (pStr == "high")
        r.priority = TaskPriority.high;
      else if (pStr == "veryHigh")
        r.priority = TaskPriority.veryHigh;
      else
        r.priority = TaskPriority.medium;

      auto result = useCase.updateTask(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "WZTask updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.completeTask(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "completed")
          .set("message", "WZTask completed successfully");

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
      auto result = useCase.deleteTask(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "WZTask deleted successfully");
        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeTask(WZTask t) {
  auto tags = t.tags.map!(tag => Json(tag)).array.toJson;

  return Json.emptyObject
    .set("id", t.id)
    .set("tenantId", t.tenantId)
    .set("assigneeId", t.assigneeId)
    .set("assigneeName", t.assigneeName)
    .set("creatorId", t.creatorId)
    .set("creatorName", t.creatorName)
    .set("title", t.title)
    .set("description", t.description)
    .set("status", t.status.to!string)
    .set("priority", t.priority.to!string)
    .set("sourceApp", t.sourceApp)
    .set("sourceTaskId", t.sourceTaskId)
    .set("actionUrl", t.actionUrl)
    .set("category", t.category)
    .set("dueDate", t.dueDate)
    .set("completedAt", t.completedAt)
    .set("createdAt", t.createdAt)
    .set("updatedAt", t.updatedAt)
    .set("tags", tags);
}
