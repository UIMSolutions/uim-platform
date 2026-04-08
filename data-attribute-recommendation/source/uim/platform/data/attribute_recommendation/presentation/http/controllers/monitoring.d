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

class MonitoringController : SAPController {
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

      auto arr = Json.emptyArray;
      foreach (ref j; jobs)
        arr ~= serializeJobSummary(j);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) jobs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetJob(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto job = uc.getTrainingJob(id, tenantId);
      if (job.jobId.length == 0) {
        writeError(res, 404, "Training job not found");
        return;
      }
      res.writeJsonBody(serializeJobSummary(job), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListDeployments(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto deps = uc.listDeploymentSummaries(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref d; deps)
        arr ~= serializeDeploymentSummary(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) deps.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePipeline(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getPipelineSummary(tenantId);

      auto j = Json.emptyObject;
      j["totalModels"] = Json(cast(long) summary.totalModels);
      j["trainedModels"] = Json(cast(long) summary.trainedModels);
      j["activeDeployments"] = Json(cast(long) summary.activeDeployments);
      j["totalTrainingJobs"] = Json(cast(long) summary.totalTrainingJobs);
      j["completedJobs"] = Json(cast(long) summary.completedJobs);
      j["failedJobs"] = Json(cast(long) summary.failedJobs);
      j["totalInferenceRequests"] = Json(summary.totalInferenceRequests);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJobSummary(ref const TrainingJobSummary s) {
    auto j = Json.emptyObject;
    j["jobId"] = Json(s.jobId);
    j["modelConfigId"] = Json(s.modelConfigId);
    j["modelName"] = Json(s.modelName);
    j["status"] = Json(s.status.to!string);
    j["metrics"] = Json(s.metrics);
    j["epochsCompleted"] = Json(cast(long) s.epochsCompleted);
    j["totalEpochs"] = Json(cast(long) s.totalEpochs);
    j["startedAt"] = Json(s.startedAt);
    j["completedAt"] = Json(s.completedAt);
    return j;
  }

  private static Json serializeDeploymentSummary(ref const DeploymentSummary s) {
    auto j = Json.emptyObject;
    j["deploymentId"] = Json(s.deploymentId);
    j["deploymentName"] = Json(s.deploymentName);
    j["status"] = Json(s.status.to!string);
    j["modelName"] = Json(s.modelName);
    j["version"] = Json(s.version_);
    j["replicas"] = Json(cast(long) s.replicas);
    j["inferenceCount"] = Json(s.inferenceCount);
    return j;
  }
}
