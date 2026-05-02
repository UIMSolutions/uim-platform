/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.provisioning_job;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.identity.provisioning.application.usecases.run_provisioning_jobs;
import uim.platform.identity.provisioning.application.dto;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;
import uim.platform.identity.provisioning.domain.types;

class ProvisioningJobController : PlatformController {
  private RunProvisioningJobsUseCase uc;

  this(RunProvisioningJobsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/provisioning-jobs", &handleCreate);
    router.get("/api/v1/provisioning-jobs", &handleList);
    router.get("/api/v1/provisioning-jobs/*", &handleGetById);
    router.post("/api/v1/provisioning-jobs/run/*", &handleRun);
    router.post("/api/v1/provisioning-jobs/run-now", &handleCreateAndRun);
    router.post("/api/v1/provisioning-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/provisioning-jobs/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateProvisioningJobRequest();
      r.tenantId = req.getTenantId;
      r.sourceSystemId = j.getString("sourceSystemId");
      r.targetSystemId = j.getString("targetSystemId");
      r.jobType = parseJobType(j.getString("jobType"));
      r.schedule = j.getString("schedule");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createJob(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "scheduled");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;

      auto items = uc.listJobs(tenantId);
      auto arr = items.map!(j => j.toJson).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

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
      auto job = uc.getJob(tenantId, id);
      if (job.isNull) {
        writeError(res, 404, "Provisioning job not found");
        return;
      }
      res.writeJsonBody(job.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;

      auto result = uc.runJob(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCreateAndRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateProvisioningJobRequest();
      r.tenantId = req.getTenantId;
      r.sourceSystemId = j.getString("sourceSystemId");
      r.targetSystemId = j.getString("targetSystemId");
      r.jobType = parseJobType(j.getString("jobType"));
      r.schedule = j.getString("schedule");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createAndRunJob(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.cancelJob(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "cancelled");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.deleteJob(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Provisioning job not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJob(const ProvisioningJob j) {
    auto job = Json.emptyObject;
    job["id"] = Json(j.id);
    job["tenantId"] = Json(j.tenantId);
    job["sourceSystemId"] = Json(j.sourceSystemId);
    job["targetSystemId"] = Json(j.targetSystemId);
    job["jobType"] = Json(j.jobType.to!string);
    job["status"] = Json(j.status.to!string);
    job["schedule"] = Json(j.schedule);
    job["totalEntities"] = Json(j.totalEntities);
    job["processedEntities"] = Json(j.processedEntities);
    job["failedEntities"] = Json(j.failedEntities);
    job["startedAt"] = Json(j.startedAt);
    job["completedAt"] = Json(j.completedAt);
    job["createdBy"] = Json(j.createdBy);
    job["createdAt"] = Json(j.createdAt);
    return job;
  }
}
