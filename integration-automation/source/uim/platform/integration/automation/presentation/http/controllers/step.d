/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.step;

// import uim.platform.integration.automation.application.usecases.manage.steps;
// import uim.platform.integration.automation.application.dto;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow_step;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class StepController : ManageHttpController {
  private ManageStepsUseCase useCase;

  this(ManageStepsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/steps", &handleListByWorkflow);
    router.get("/api/v1/steps/*", &handleGet);
    router.get("/api/v1/my-tasks", &handleMyTasks);
    router.post("/api/v1/steps/start/*", &handleStart);
    router.post("/api/v1/steps/complete/*", &handleComplete);
    router.post("/api/v1/steps/fail/*", &handleFail);
    router.post("/api/v1/steps/skip/*", &handleSkip);
    router.put("/api/v1/steps/assign/*", &handleAssign);
  }

  override protected void handleListByWorkflow(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto workflowId = WorkflowId(req.headers.get("X-Workflow-Id", ""));
      auto steps = useCase.listSteps(tenantId, workflowId);

      auto arr = steps.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", steps.length)
        .set("workflowId", workflowId)
        .set("message", "Steps retrieved successfully");

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
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    auto step = useCase.getStep(tenantId, id);
    if (step.isNull)
      return errorResponse("Step not found", "Not Found", 404);

    return successResponse("Step retrieved successfully", 200, step.toJson);
  }

  protected Json myTasksHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = UserId(req.headers.get("X-User-Id", ""));
    if (id.isNull)
      return errorResponse("User ID is required in X-User-Id header", "Bad Request", 400);

    auto tasks = useCase.getMyTasks(tenantId, id);
    auto list = tasks.map!(s => s.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", list)
      .set("totalCount", tasks.length);

    return successResponse("My tasks retrieved successfully", 200, responseData);
  }

  protected void handleMyTasks(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto userId = UserId(req.headers.get("X-User-Id", ""));
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

  protected void handlert(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto userId = UserId(req.headers.get("X-User-Id", ""));

      auto result = useCase.startStep(tenantId, id, userId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "inProgress")
          .set("message", "Step started successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = CompleteStepRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.completedBy = UserId(req.headers.get("X-User-Id", ""));
      r.result = data.getString("result");

      auto result = useCase.completeStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed")
          .set("message", "Step completed successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = FailStepRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.reportedBy = UserId(req.headers.get("X-User-Id", ""));
      r.errorMessage = data.getString("errorMessage");

      auto result = useCase.failStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "failed")
          .set("message", "Step marked as failed");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSkip(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = SkipStepRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.skippedBy = UserId(req.headers.get("X-User-Id", ""));
      r.reason = data.getString("reason");

      auto result = useCase.skipStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "skipped")
          .set("message", "Step skipped successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = AssignStepRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.assignedTo = UserId(data.getString("assignedTo"));
      r.assignedRole = data.getString("assignedRole");

      auto result = useCase.assignStep(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Step assigned successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
