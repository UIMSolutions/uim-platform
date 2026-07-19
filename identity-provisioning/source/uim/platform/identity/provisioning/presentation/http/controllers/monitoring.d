/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.controllers.monitoring_controller;

// import uim.platform.identity.provisioning.application.usecases.monitor_provisioning;
// import uim.platform.identity.provisioning.domain.entities.provisioning_log;
// import uim.platform.identity.provisioning.domain.entities.provisioned_entity;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning;
mixin(ShowModule!());

@safe:
class MonitoringController : HttpController {
  private MonitorProvisioningUseCase usecase;

  this(MonitorProvisioningUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/monitoring/jobs", &handleListJobSummaries);
    router.get("/api/v1/monitoring/jobs/*", &handleGetJobSummary);
    router.get("/api/v1/monitoring/logs/*", &handleGetJobLogs);
    router.get("/api/v1/monitoring/entities", &handleListEntities);
    router.get("/api/v1/monitoring/pipeline", &handlePipeline);
  }

  protected Json listJobSummariesHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listJobSummaries(tenantId);

    auto arr = items.map!(s => s.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Job summaries retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleListJobSummaries", "listJobSummariesHandler"));

  protected Json getJobSummaryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ProvisioningJobId(precheck.id);
    auto summary = usecase.getJobSummary(tenantId, id);
    if (summary.jobId.isEmpty)
      return errorResponse("Job not found", 404);

    auto resp = summary.toJson();

    return successResponse("Job summary retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleGetJobSummary", "getJobSummaryHandler"));

  protected Json getJobLogsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto jobId = ProvisioningJobId(precheck.id);
    auto logs = usecase.getJobLogs(tenantId, jobId);
    if (logs.length == 0)
      return errorResponse("No logs found for this job", 404);

    auto arr = logs.map!(l => l.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", logs.length);

    return successResponse("Job execution logs retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleGetJobLogs", "getJobLogsHandler"));

  protected Json listEntitiesHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listProvisionedEntities(tenantId);

    auto arr = items.map!(e => e.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length)
      .set("message", "Provisioned entities retrieved successfully");

    return successResponse("Provisioned entities retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleListEntities", "listEntitiesHandler"));

  protected Json pipelineHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto summary = usecase.getPipelineSummary(tenantId);

    auto j = Json.emptyObject
      .set("totalSourceSystems", summary.totalSourceSystems)
      .set("activeSourceSystems", summary.activeSourceSystems)
      .set("totalTargetSystems", summary.totalTargetSystems)
      .set("activeTargetSystems", summary.activeTargetSystems)
      .set("totalJobs", summary.totalJobs)
      .set("completedJobs", summary.completedJobs)
      .set("failedJobs", summary.failedJobs)
      .set("runningJobs", summary.runningJobs)
      .set("totalProvisionedEntities", summary.totalProvisionedEntities)
      .set("message", "Pipeline summary retrieved successfully");

    return successResponse("Pipeline summary retrieved successfully", "Retrieved", 200, j);
  }

mixin(HandleTemplate!("handlePipeline", "pipelineHandler"));

}
