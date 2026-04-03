module presentation.http.step;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_steps;
import application.dto;
import domain.types;
import domain.entities.workflow_step;
import uim.platform.xyz.presentation.http.json_utils;

class StepController
{
  private ManageStepsUseCase useCase;

  this(ManageStepsUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.get("/api/v1/steps", &handleListByWorkflow);
    router.get("/api/v1/steps/*", &handleGetById);
    router.get("/api/v1/my-tasks", &handleMyTasks);
    router.post("/api/v1/steps/start/*", &handleStart);
    router.post("/api/v1/steps/complete/*", &handleComplete);
    router.post("/api/v1/steps/fail/*", &handleFail);
    router.post("/api/v1/steps/skip/*", &handleSkip);
    router.put("/api/v1/steps/assign/*", &handleAssign);
  }

  private void handleListByWorkflow(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto workflowId = req.headers.get("X-Workflow-Id", "");
      auto steps = useCase.listSteps(workflowId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; steps)
        arr ~= serializeStep(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) steps.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto step = useCase.getStep(id, tenantId);
      if (step is null)
      {
        writeError(res, 404, "Step not found");
        return;
      }
      res.writeJsonBody(serializeStep(*step), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleMyTasks(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto userId = req.headers.get("X-User-Id", "");
      auto tasks = useCase.getMyTasks(tenantId, userId);

      auto arr = Json.emptyArray;
      foreach (ref s; tasks)
        arr ~= serializeStep(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) tasks.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto userId = req.headers.get("X-User-Id", "");

      auto result = useCase.startStep(id, tenantId, userId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("inProgress");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = CompleteStepRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.completedBy = req.headers.get("X-User-Id", "");
      r.result = j.getString("result");

      auto result = useCase.completeStep(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("completed");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleFail(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = FailStepRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.reportedBy = req.headers.get("X-User-Id", "");
      r.errorMessage = j.getString("errorMessage");

      auto result = useCase.failStep(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("failed");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSkip(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = SkipStepRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.skippedBy = req.headers.get("X-User-Id", "");
      r.reason = j.getString("reason");

      auto result = useCase.skipStep(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("skipped");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = AssignStepRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.assignedTo = j.getString("assignedTo");
      r.assignedRole = j.getString("assignedRole");

      auto result = useCase.assignStep(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeStep(ref const WorkflowStep s)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["workflowId"] = Json(s.workflowId);
    j["tenantId"] = Json(s.tenantId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["type"] = Json(s.type_.to!string);
    j["status"] = Json(s.status.to!string);
    j["priority"] = Json(s.priority.to!string);
    j["sequenceNumber"] = Json(s.sequenceNumber);
    j["assignedTo"] = Json(s.assignedTo);
    j["assignedRole"] = Json(s.assignedRole);
    j["instructions"] = Json(s.instructions);
    j["automationEndpoint"] = Json(s.automationEndpoint);
    j["sourceSystemId"] = Json(s.sourceSystemId);
    j["targetSystemId"] = Json(s.targetSystemId);
    j["result"] = Json(s.result);
    j["errorMessage"] = Json(s.errorMessage);
    j["startedAt"] = Json(s.startedAt);
    j["completedAt"] = Json(s.completedAt);
    j["createdAt"] = Json(s.createdAt);
    j["estimatedDurationMinutes"] = Json(s.estimatedDurationMinutes);

    if (s.dependencies.length > 0)
      j["dependencies"] = toJsonArray(s.dependencies);

    return j;
  }
}
