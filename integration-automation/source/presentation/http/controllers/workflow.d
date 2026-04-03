module presentation.http.workflow;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.manage_workflows;
import uim.platform.xyz.application.dto;
import domain.types;
import domain.entities.workflow;
import uim.platform.xyz.presentation.http.json_utils;

class WorkflowController
{
  private ManageWorkflowsUseCase useCase;

  this(ManageWorkflowsUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/workflows", &handleCreate);
    router.get("/api/v1/workflows", &handleList);
    router.get("/api/v1/workflows/*", &handleGetById);
    router.post("/api/v1/workflows/start/*", &handleStart);
    router.post("/api/v1/workflows/suspend/*", &handleSuspend);
    router.post("/api/v1/workflows/resume/*", &handleResume);
    router.post("/api/v1/workflows/terminate/*", &handleTerminate);
    router.delete_("/api/v1/workflows/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateWorkflowRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.sourceSystemId = j.getString("sourceSystemId");
      r.targetSystemId = j.getString("targetSystemId");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createWorkflow(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto workflows = useCase.listWorkflows(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref w; workflows)
        arr ~= serializeWorkflow(w);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) workflows.length);
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
      auto wf = useCase.getWorkflow(id, tenantId);
      if (wf is null)
      {
        writeError(res, 404, "Workflow not found");
        return;
      }
      res.writeJsonBody(serializeWorkflow(*wf), 200);
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
      auto result = useCase.startWorkflow(id, tenantId);
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

  private void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.suspendWorkflow(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("suspended");
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

  private void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.resumeWorkflow(id, tenantId);
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

  private void handleTerminate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.terminateWorkflow(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("terminated");
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteWorkflow(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeWorkflow(ref const Workflow w)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(w.id);
    j["tenantId"] = Json(w.tenantId);
    j["scenarioId"] = Json(w.scenarioId);
    j["name"] = Json(w.name);
    j["description"] = Json(w.description);
    j["status"] = Json(w.status.to!string);
    j["currentStepIndex"] = Json(w.currentStepIndex);
    j["totalSteps"] = Json(w.totalSteps);
    j["completedSteps"] = Json(w.completedSteps);
    j["sourceSystemId"] = Json(w.sourceSystemId);
    j["targetSystemId"] = Json(w.targetSystemId);
    j["createdBy"] = Json(w.createdBy);
    j["startedAt"] = Json(w.startedAt);
    j["completedAt"] = Json(w.completedAt);
    j["createdAt"] = Json(w.createdAt);
    j["updatedAt"] = Json(w.updatedAt);
    return j;
  }
}
