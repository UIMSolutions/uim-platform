/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers
  .monitoring;

// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.monitor_training;

import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());
@safe:

class MonitoringController : HttpController {
  private MonitorTrainingUseCase usecase;

  this(MonitorTrainingUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/monitoring/jobs", &handleListJobs);
    router.get("/api/v1/monitoring/jobs/*", &handleGetJob);
    router.get("/api/v1/monitoring/deployments", &handleListDeployments);
    router.get("/api/v1/monitoring/pipeline", &handlePipeline);
  }

  protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto jobs = usecase.listTrainingJobs(tenantId);
    auto list = jobs.map!(j => j.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse( "Training job list retrieved successfully", 200, responseData);
  }

  protected Json jobHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TrainingJobId(precheck.id);

    auto job = usecase.getTrainingJob(tenantId, id);
    if (job.isNull)
      return errorResponse("Training job not found", 404);

    auto responseData = job.toJson();
    return successResponse( "Training job retrieved successfully", 200, responseData);
  }

  protected void handleJob(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
     auto response = jobHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json listDeploymentsHandler(HTTPServerRequest req) {
     auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto deps = usecase.listDeploymentSummaries(tenantId);
    auto list = deps.map!(d => d.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Deployment list retrieved successfully", 200, responseData);
  }
  protected void handleListDeployments(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listDeploymentsHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json pipelineHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto summary = usecase.getPipelineSummary(tenantId);

    auto responseData = Json.emptyObject
      .set("totalModels", summary.totalModels)
      .set("trainedModels", summary.trainedModels)
      .set("activeDeployments", summary.activeDeployments)
      .set("totalTrainingJobs", summary.totalTrainingJobs)
      .set("completedJobs", summary.completedJobs)
      .set("failedJobs", summary.failedJobs)
      .set("totalInferenceRequests", summary.totalInferenceRequests);

    return successResponse("Pipeline summary retrieved successfully", 200, responseData);
  }

  protected void handleGetPipeline(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = pipelineHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDeploymentSummary(const DeploymentSummary s) {
    return Json.emptyObject
      .set("deploymentId", s.deploymentId)
      .set("deploymentName", s.deploymentName)
      .set("status", s.status.to!string)
      .set("modelName", s.modelName)
      .set("version", s.version_)
      .set("replicas", s.replicas)
      .set("inferenceCount", s.inferenceCount);
  }
}
