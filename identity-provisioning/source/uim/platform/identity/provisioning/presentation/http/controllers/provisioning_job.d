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
import uim.platform.identity.provisioning.presentation.http.json_utils;

class ProvisioningJobController {
  private RunProvisioningJobsUseCase uc;

  this(RunProvisioningJobsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("scheduled");
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
      auto tenantId = req.getTenantId;
      auto items = uc.listJobs(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref j; items)
        arr ~= serializeJob(j);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto job = uc.getJob(id, tenantId);
      if (job is null) {
        writeError(res, 404, "Provisioning job not found");
        return;
      }
      res.writeJsonBody(serializeJob(*job), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto result = uc.runJob(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("completed");
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("completed");
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
      auto tenantId = req.getTenantId;
      auto result = uc.cancelJob(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("cancelled");
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
      auto tenantId = req.getTenantId;
      auto result = uc.deleteJob(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
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

  private static Json serializeJob(ref const ProvisioningJob j) {
    auto o = Json.emptyObject;
    o["id"] = Json(j.id);
    o["tenantId"] = Json(j.tenantId);
    o["sourceSystemId"] = Json(j.sourceSystemId);
    o["targetSystemId"] = Json(j.targetSystemId);
    o["jobType"] = Json(j.jobType.to!string);
    o["status"] = Json(j.status.to!string);
    o["schedule"] = Json(j.schedule);
    o["totalEntities"] = Json(j.totalEntities);
    o["processedEntities"] = Json(j.processedEntities);
    o["failedEntities"] = Json(j.failedEntities);
    o["startedAt"] = Json(j.startedAt);
    o["completedAt"] = Json(j.completedAt);
    o["createdBy"] = Json(j.createdBy);
    o["createdAt"] = Json(j.createdAt);
    return o;
  }
}
