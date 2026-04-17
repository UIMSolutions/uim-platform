/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.monitoring;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.integration.automation.application.usecases.monitor_executions;
import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.execution_log;
import uim.platform.integration.automation.presentation.http.json_utils;

class MonitoringController : PlatformController {
  private MonitorExecutionsUseCase useCase;

  this(MonitorExecutionsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/monitoring/logs", &handleGetLogs);
    router.get("/api/v1/monitoring/logs/workflow/*", &handleGetWorkflowLogs);
    router.get("/api/v1/monitoring/logs/step/*", &handleGetStepLogs);
    router.get("/api/v1/monitoring/failures", &handleGetFailures);
    router.get("/api/v1/monitoring/summary/*", &handleGetSummary);
  }

  private void handleGetLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto logs = useCase.getAllLogs(tenantId);

      auto arr = Json.emptyArray;
      foreach (l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetWorkflowLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto workflowId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto logs = useCase.getWorkflowLogs(workflowtenantId, id);

      auto arr = Json.emptyArray;
      foreach (l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetStepLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto stepId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto logs = useCase.getStepLogs(steptenantId, id);

      auto arr = Json.emptyArray;
      foreach (l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetFailures(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto logs = useCase.getFailures(tenantId);

      auto arr = Json.emptyArray;
      foreach (l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto workflowId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto summary = useCase.getWorkflowSummary(workflowtenantId, id);

      auto j = Json.emptyObject
      .set("workflowId", summary.workflowId)
      .set("workflowName", summary.workflowName)
      .set("status", summary.status.to!string)
      .set("totalSteps", summary.totalSteps)
      .set("completedSteps", summary.completedSteps)
      .set("inProgressSteps", summary.inProgressSteps)
      .set("pendingSteps", summary.pendingSteps)
      .set("failedSteps", summary.failedSteps)
      .set("skippedSteps", summary.skippedSteps)
      .set("totalLogEntries", summary.totalLogEntries);
      
      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeLog(const ExecutionLog l) {
    return Json.emptyObject
    .set("id", l.id)
    .set("workflowId", l.workflowId)
    .set("stepId", l.stepId)
    .set("tenantId", l.tenantId)
    .set("action", l.action)
    .set("outcome", l.outcome.to!string)
    .set("message", l.message)
    .set("details", l.details)
    .set("executedBy", l.executedBy)
    .set("durationMs", l.durationMs)
    .set("timestamp", l.timestamp);
  }
}
