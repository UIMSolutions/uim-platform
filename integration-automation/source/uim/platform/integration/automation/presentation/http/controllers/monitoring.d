/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.monitoring;




// import uim.platform.integration.automation.application.usecases.monitor_executions;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.execution_log;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class MonitoringController : PlatformController {
  private MonitorExecutionsUseCase useCase;

  this(MonitorExecutionsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/monitoring/logs", &handleGetLogs);
    router.get("/api/v1/monitoring/logs/workflow/*", &handleWorkflowLogs);
    router.get("/api/v1/monitoring/logs/step/*", &handleStepLogs);
    router.get("/api/v1/monitoring/failures", &handleFailures);
    router.get("/api/v1/monitoring/summary/*", &handleSummary);
  }

  protected void handleLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      auto logs = useCase.getAllLogs(tenantId);
      auto arr = logs.map!(l => l.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", logs.length)
        .set("message", "Execution logs retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleWorkflowLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto workflowId = precheck.id;
      auto tenantId = precheck.tenantId;

      auto logs = useCase.getWorkflowLogs(tenantId, workflowId);
      auto arr = logs.map!(l => l.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", logs.length)
        .set("message", "Workflow execution logs retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleStepLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto stepId = precheck.id;
      auto tenantId = precheck.tenantId;
      auto logs = useCase.getStepLogs(tenantId, stepId);

      auto arr = logs.map!(l => l.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", logs.length)
        .set("message", "Step logs retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleFailures(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      
      auto items = useCase.getFailures(tenantId);
      auto arr = items.map!(l => l.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Failures retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto workflowId = precheck.id;
      auto tenantId = precheck.tenantId;
      auto summary = useCase.getWorkflowSummary(tenantId, workflowId);

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
}
