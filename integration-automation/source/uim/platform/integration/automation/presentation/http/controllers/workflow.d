/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.workflow;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.integration.automation.application.usecases.manage.workflows;
import uim.platform.integration.automation.application.dto;
import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow;
import uim.platform.integration.automation.presentation.http.json_utils;

class WorkflowController : PlatformController {
  private ManageWorkflowsUseCase useCase;

  this(ManageWorkflowsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/workflows", &handleCreate);
    router.get("/api/v1/workflows", &handleList);
    router.get("/api/v1/workflows/*", &handleGetById);
    router.post("/api/v1/workflows/start/*", &handleStart);
    router.post("/api/v1/workflows/suspend/*", &handleSuspend);
    router.post("/api/v1/workflows/resume/*", &handleResume);
    router.post("/api/v1/workflows/terminate/*", &handleTerminate);
    router.delete_("/api/v1/workflows/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateWorkflowRequest();
      r.tenantId = req.getTenantId;
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.sourceSystemConnectionId = j.getString("sourceSystemConnectionId");
      r.targetSystemConnectionId = j.getString("targetSystemConnectionId");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createWorkflow(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto workflows = useCase.listWorkflows(tenantId);

      auto arr = Json.emptyArray;
      foreach (w; workflows)
        arr ~= serializeWorkflow(w);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(workflows.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto wf = useCase.getWorkflow(tenantId, id);
      if (wf is null) {
        writeError(res, 404, "Workflow not found");
        return;
      }
      res.writeJsonBody(serializeWorkflow(*wf), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.startWorkflow(tenantId, id);
      if (result.isSuccess()) {
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
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.suspendWorkflow(tenantId, id);
      if (result.isSuccess()) {
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
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.resumeWorkflow(tenantId, id);
      if (result.isSuccess()) {
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
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleTerminate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.terminateWorkflow(tenantId, id);
      if (result.isSuccess()) {
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
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteWorkflow(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeWorkflow(const Workflow w) {
    return Json.emptyObject
     .set("id", w.id)
     .set("tenantId", w.tenantId)
     .set("scenarioId", w.scenarioId)
     .set("name", w.name)
     .set("description", w.description)
     .set("status", w.status.to!string)
     .set("currentStepIndex", w.currentStepIndex)
     .set("totalSteps", w.totalSteps)
     .set("completedSteps", w.completedSteps)
     .set("sourceSystemConnectionId", w.sourceSystemConnectionId)
     .set("targetSystemConnectionId", w.targetSystemConnectionId)
     .set("createdBy", w.createdBy)
     .set("startedAt", w.startedAt)
     .set("completedAt", w.completedAt)
     .set("createdAt", w.createdAt)
     .set("updatedAt", w.updatedAt);
  }
}
