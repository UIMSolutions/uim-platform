/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.step;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.integration.automation.application.usecases.manage.steps;
import uim.platform.integration.automation.application.dto;
import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow_step;

class StepController : PlatformController {
  private ManageStepsUseCase useCase;

  this(ManageStepsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/steps", &handleListByWorkflow);
    router.get("/api/v1/steps/*", &handleGetById);
    router.get("/api/v1/my-tasks", &handleMyTasks);
    router.post("/api/v1/steps/start/*", &handleStart);
    router.post("/api/v1/steps/complete/*", &handleComplete);
    router.post("/api/v1/steps/fail/*", &handleFail);
    router.post("/api/v1/steps/skip/*", &handleSkip);
    router.put("/api/v1/steps/assign/*", &handleAssign);
  }

  private void handleListByWorkflow(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto workflowId = req.headers.get("X-Workflow-Id", "");
      auto steps = useCase.listSteps(tenantId, workflowId);

      auto arr = steps.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", steps.length)
          .set("workflowId", workflowId);
          
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto step = useCase.getStep(tenantId, id);
      if (step.isNull) {
        writeError(res, 404, "Step not found");
        return;
      }
      res.writeJsonBody(step.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleMyTasks(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto userId = req.headers.get("X-User-Id", "");
      auto tasks = useCase.getMyTasks(tenantId, userId);

      auto arr = tasks.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(tasks.length));
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto userId = req.headers.get("X-User-Id", "");

      auto result = useCase.startStep(tenantId, id, userId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "inProgress");

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
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = CompleteStepRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.completedBy = req.headers.get("X-User-Id", "");
      r.result = j.getString("result");

      auto result = useCase.completeStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleFail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = FailStepRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.reportedBy = UserId(req.headers.get("X-User-Id", ""));
      r.errorMessage = j.getString("errorMessage");

      auto result = useCase.failStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "failed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSkip(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = SkipStepRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.skippedBy = UserId(req.headers.get("X-User-Id", ""));
      r.reason = j.getString("reason");

      auto result = useCase.skipStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "skipped");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = AssignStepRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.assignedTo = UserId(j.getString("assignedTo"));
      r.assignedRole = j.getString("assignedRole");

      auto result = useCase.assignStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeStep(const WorkflowStep s) {
    auto j = Json.emptyObject
      .set("id", Json(s.id))
      .set("workflowId", Json(s.workflowId))
      .set("tenantId", Json(s.tenantId))
      .set("name", Json(s.name))
      .set("description", Json(s.description))
      .set("type", Json(s.type_.to!string))
      .set("status", Json(s.status.to!string))
      .set("priority", Json(s.priority.to!string))
      .set("sequenceNumber", Json(s.sequenceNumber))
      .set("assignedTo", Json(s.assignedTo))
      .set("assignedRole", Json(s.assignedRole))
      .set("instructions", Json(s.instructions))
      .set("automationEndpoint", Json(s.automationEndpoint))
      .set("sourceSystemConnectionId", Json(s.sourceSystemConnectionId))
      .set("targetSystemConnectionId", Json(s.targetSystemConnectionId))
      .set("result", Json(s.result))
      .set("errorMessage", Json(s.errorMessage))
      .set("startedAt", Json(s.startedAt))
      .set("completedAt", Json(s.completedAt))
      .set("createdAt", Json(s.createdAt))
      .set("estimatedDurationMinutes", Json(s.estimatedDurationMinutes));

    if (s.dependencies.length > 0)
      j["dependencies"] = toJsonArray(s.dependencies);

    return j;
  }
}
