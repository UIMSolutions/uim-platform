module presentation.http.monitoring;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.monitor_executions;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.execution_log;
import uim.platform.xyz.presentation.http.json_utils;

class MonitoringController
{
  private MonitorExecutionsUseCase useCase;

  this(MonitorExecutionsUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.get("/api/v1/monitoring/logs", &handleGetLogs);
    router.get("/api/v1/monitoring/logs/workflow/*", &handleGetWorkflowLogs);
    router.get("/api/v1/monitoring/logs/step/*", &handleGetStepLogs);
    router.get("/api/v1/monitoring/failures", &handleGetFailures);
    router.get("/api/v1/monitoring/summary/*", &handleGetSummary);
  }

  private void handleGetLogs(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto logs = useCase.getAllLogs(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetWorkflowLogs(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto workflowId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto logs = useCase.getWorkflowLogs(workflowId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetStepLogs(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto stepId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto logs = useCase.getStepLogs(stepId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetFailures(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto logs = useCase.getFailures(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetSummary(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto workflowId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto summary = useCase.getWorkflowSummary(workflowId, tenantId);

      auto j = Json.emptyObject;
      j["workflowId"] = Json(summary.workflowId);
      j["workflowName"] = Json(summary.workflowName);
      j["status"] = Json(summary.status.to!string);
      j["totalSteps"] = Json(summary.totalSteps);
      j["completedSteps"] = Json(summary.completedSteps);
      j["inProgressSteps"] = Json(summary.inProgressSteps);
      j["pendingSteps"] = Json(summary.pendingSteps);
      j["failedSteps"] = Json(summary.failedSteps);
      j["skippedSteps"] = Json(summary.skippedSteps);
      j["totalLogEntries"] = Json(summary.totalLogEntries);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeLog(ref const ExecutionLog l)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(l.id);
    j["workflowId"] = Json(l.workflowId);
    j["stepId"] = Json(l.stepId);
    j["tenantId"] = Json(l.tenantId);
    j["action"] = Json(l.action);
    j["outcome"] = Json(l.outcome.to!string);
    j["message"] = Json(l.message);
    j["details"] = Json(l.details);
    j["executedBy"] = Json(l.executedBy);
    j["durationMs"] = Json(l.durationMs);
    j["timestamp"] = Json(l.timestamp);
    return j;
  }
}
