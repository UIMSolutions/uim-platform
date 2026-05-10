/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.replication;


// import vibe.http.router;
// import vibe.data.json;

import uim.platform.master_data_integration.application.usecases.manage.replication_jobs;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.replication_job;
import uim.platform.master_data_integration.domain.types;

class ReplicationController : PlatformController {
  private ManageReplicationJobsUseCase usecase;

  this(ManageReplicationJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/replication-jobs", &handleCreate);
    router.get("/api/v1/replication-jobs", &handleList);
    router.get("/api/v1/replication-jobs/*", &handleGet);
    router.post("/api/v1/replication-jobs/start/*", &handleStart);
    router.post("/api/v1/replication-jobs/pause/*", &handlePause);
    router.post("/api/v1/replication-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/replication-jobs/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateReplicationJobRequest r;
      r.tenantId = tenantId;
      r.distributionModelId = j.getString("distributionModelId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.trigger = j.getString("trigger");
      r.categories = getStrings(j, "categories");
      r.sourceClientId = j.getString("sourceClientId");
      r.targetClientIds = getStrings(j, "targetClientIds");
      r.isInitialLoad = j.getBoolean("isInitialLoad");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
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
      auto tenantId = req.getTenantId;
      auto status = req.params.get("status", "");
      auto modelId = DistributionModelId(req.params.get("distributionModelId", ""));

      ReplicationJob[] jobs;
      if (!status.isEmpty)
        jobs = usecase.listReplicationJobs(tenantId, status);
      else if (!modelId.isEmpty)
        jobs = usecase.listReplicationJobs(tenantId, modelId);
      else
        jobs = usecase.listReplicationJobs(tenantId);

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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ReplicationJobId(extractIdFromPath(req.requestURI));

      auto job = usecase.getReplicationJob(tenantId, id);
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
      auto tenantId = req.getTenantId;
      auto id = ReplicationJobId(extractIdFromPath(req.requestURI));

      auto result = usecase.startReplicationJob(tenantId, id);
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
      auto tenantId = req.getTenantId;
      auto id = ReplicationJobId(extractIdFromPath(req.requestURI));
      auto result = usecase.pauseReplicationJob(tenantId, id);
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
      auto tenantId = req.getTenantId;
      auto id = ReplicationJobId(extractIdFromPath(req.requestURI));
      auto result = usecase.cancelReplicationJob(tenantId, id);
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
      auto tenantId = req.getTenantId;
      auto id = ReplicationJobId(extractIdFromPath(req.requestURI));
      auto result = usecase.deleteReplicationJob(tenantId, id);
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

}
