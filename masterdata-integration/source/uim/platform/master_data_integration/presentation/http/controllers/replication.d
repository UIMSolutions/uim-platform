/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.replication;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage.replication_jobs;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.replication_job;
import uim.platform.master_data_integration.domain.types;

class ReplicationController : PlatformController {
  private ManageReplicationJobsUseCase uc;

  this(ManageReplicationJobsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/replication-jobs", &handleCreate);
    router.get("/api/v1/replication-jobs", &handleList);
    router.get("/api/v1/replication-jobs/*", &handleGetById);
    router.post("/api/v1/replication-jobs/start/*", &handleStart);
    router.post("/api/v1/replication-jobs/pause/*", &handlePause);
    router.post("/api/v1/replication-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/replication-jobs/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateReplicationJobRequest r;
      r.tenantId = req.getTenantId;
      r.distributionModelId = j.getString("distributionModelId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.trigger = j.getString("trigger");
      r.categories = getStringArray(j, "categories");
      r.sourceClientId = j.getString("sourceClientId");
      r.targetClientIds = getStringArray(j, "targetClientIds");
      r.isInitialLoad = j.getBoolean("isInitialLoad");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto status = req.params.get("status", "");
      auto modelId = req.params.get("distributionModelId", "");

      ReplicationJob[] jobs;
      if (status.length > 0)
        jobs = uc.listByStatus(tenantId, status);
      else if (modelId.length > 0)
        jobs = uc.listByDistributionModel(tenantId, modelId);
      else
        jobs = uc.listByTenant(tenantId);

      auto arr = jobs.map!(j => j.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", jobs.length)
        .set("message", "Replication jobs retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto job = uc.getJob(id);
      if (job.isNull) {
        writeError(res, 404, "Replication job not found");
        return;
      }
      res.writeJsonBody(job.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.startJob(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job started");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.pauseJob(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job paused");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.cancelJob(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job canceled");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteJob(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job deleted");

        res.writeJsonBody(resp, 204);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeJob(ReplicationJob j) {
    auto o = Json.emptyObject;
    o["id"] = Json(j.id);
    o["tenantId"] = Json(j.tenantId);
    o["distributionModelId"] = Json(j.distributionModelId);
    o["name"] = Json(j.name);
    o["description"] = Json(j.description);
    o["status"] = Json(j.status.to!string);
    o["trigger"] = Json(j.trigger.to!string);

    auto catsArr = Json.emptyArray;
    foreach (cat; j.categories)
      catsArr ~= Json(cat.to!string);
    o["categories"] = catsArr;

    o["sourceClientId"] = Json(j.sourceClientId);
    o["targetClientIds"] = serializeStrArray(j.targetClientIds);
    o["totalRecords"] = Json(j.totalRecords);
    o["processedRecords"] = Json(j.processedRecords);
    o["successRecords"] = Json(j.successRecords);
    o["errorRecords"] = Json(j.errorRecords);
    o["skippedRecords"] = Json(j.skippedRecords);
    o["errorMessages"] = serializeStrArray(j.errorMessages);
    o["lastDeltaToken"] = Json(j.lastDeltaToken);
    o["isInitialLoad"] = Json(j.isInitialLoad);
    o["startedAt"] = Json(j.startedAt);
    o["completedAt"] = Json(j.completedAt);
    o["createdAt"] = Json(j.createdAt);
    o["createdBy"] = Json(j.createdBy);
    return o;
  }
}
