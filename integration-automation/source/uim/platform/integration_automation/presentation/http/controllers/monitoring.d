/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.presentation.http.controllers.monitoring;

// import uim.platform.integration_automation.application.usecases.monitor_executions;

// import uim.platform.integration_automation.domain.entities.execution_log;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
class MonitoringController : ManageHttpController {
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

  protected Json getLogsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto logs = useCase.getAllLogs(tenantId);
    auto arr = logs.map!(l => l.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", logs.length)
      .set("message", "Execution logs retrieved successfully");

    return successResponse("Execution logs retrieved successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleGetLogs", "getLogsHandler"));

  protected Json getWorkflowLogsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto workflowId = precheck.id;
    auto tenantId = precheck.tenantId;

    auto logs = useCase.getWorkflowLogs(tenantId, workflowId);
    auto arr = logs.map!(l => l.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", logs.length)
      .set("message", "Workflow execution logs retrieved successfully");

    return successResponse("Workflow execution logs retrieved successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleWorkflowLogs", "getWorkflowLogsHandler"));

  protected Json getStepLogsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto stepId = precheck.id;
    auto tenantId = precheck.tenantId;
    auto logs = useCase.getStepLogs(tenantId, stepId);

    auto arr = logs.map!(l => l.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", logs.length)
      .set("message", "Step logs retrieved successfully");

    return successResponse("Step logs retrieved successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleStepLogs", "getStepLogsHandler"));

  protected Json failuresHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = useCase.getFailures(tenantId);
    auto arr = items.map!(l => l.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length)
      .set("message", "Failures retrieved successfully");

    return successResponse("Failures retrieved successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleFailures", "failuresHandler"));

  protected Json summaryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

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

    return successResponse("Workflow summary retrieved successfully", 200, j);
  }

  mixin(HandleTemplate!("handleSummary", "summaryHandler"));

}
