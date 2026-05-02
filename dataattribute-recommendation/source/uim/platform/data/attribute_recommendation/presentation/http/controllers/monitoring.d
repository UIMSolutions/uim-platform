/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.presentation.http.controllers
  .monitoring_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.monitor_training;
// import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:

class MonitoringController : PlatformController {
  private MonitorTrainingUseCase uc;

  this(MonitorTrainingUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/monitoring/jobs", &handleListJobs);
    router.get("/api/v1/monitoring/jobs/*", &handleGetJob);
    router.get("/api/v1/monitoring/deployments", &handleListDeployments);
    router.get("/api/v1/monitoring/pipeline", &handlePipeline);
  }

  private void handleListJobs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto jobs = uc.listTrainingJobs(tenantId);

      auto arr = jobs.map!(j => j.toJson).array;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(jobs.length))
            .set("message", "Training jobs retrieved successfully");
            
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetJob(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto job = uc.getTrainingJob(tenantId, id);
      if (job.jobId.isEmpty) {
        writeError(res, 404, "Training job not found");
        return;
      }
      res.writeJsonBody(serializeJobSummary(job), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListDeployments(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto deps = uc.listDeploymentSummaries(tenantId);

      auto arr = deps.map!(d => d.toJson).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", deps.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePipeline(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getPipelineSummary(tenantId);

      auto response = Json.emptyObject
        .set("totalModels", summary.totalModels)
        .set("trainedModels", summary.trainedModels)
        .set("activeDeployments", summary.activeDeployments)
        .set("totalTrainingJobs", summary.totalTrainingJobs)
        .set("completedJobs", summary.completedJobs)
        .set("failedJobs", summary.failedJobs)
        .set("totalInferenceRequests", summary.totalInferenceRequests);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJobSummary(const TrainingJobSummary s) {
    return Json.emptyObject
      .set("jobId", s.jobId)
      .set("modelConfigId", s.modelConfigId)
      .set("modelName", s.modelName)
      .set("status", s.status.to!string)
      .set("metrics", s.metrics)
      .set("epochsCompleted", s.epochsCompleted)
      .set("totalEpochs", s.totalEpochs)
      .set("startedAt", s.startedAt)
      .set("completedAt", s.completedAt);
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
