/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.replication;





// import uim.platform.master_data_integration.application.usecases.manage.replication_jobs;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.replication_job;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class ReplicationController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
              CreateReplicationJobRequest r;
      r.tenantId = tenantId;
      r.distributionModelId = data.getString("distributionModelId");
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.trigger = data.getString("trigger");
      r.categories = data.getStrings("categories");
      r.sourceClientId = data.getString("sourceClientId");
      r.targetClientIds = data.getStrings("targetClientIds");
      r.isInitialLoad = data.getBoolean("isInitialLoad");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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
        .set("totalCount", jobs.length);

      return successResponse("Replication jobs retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = ReplicationJobId(precheck.id);

      auto job = usecase.getReplicationJob(tenantId, id);
      if (job.isNull) 
      return errorResponse("Replication job not found", 404);

      auto response = job.toJson();
      return successResponse("Replication job retrieved successfully", 200, response);
    }
  }

  protected void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ReplicationJobId(precheck.id);

      auto result = usecase.startReplicationJob(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job started");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ReplicationJobId(precheck.id);
      auto result = usecase.pauseReplicationJob(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job paused");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ReplicationJobId(precheck.id);
      auto result = usecase.cancelReplicationJob(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job canceled");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = ReplicationJobId(precheck.id);
      auto result = usecase.deleteReplicationJob(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Replication job deleted");

        res.writeJsonBody(resp, 204);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
