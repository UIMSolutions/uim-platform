/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.provisioning_job;




// import uim.platform.identity.provisioning.application.usecases.run_provisioning_jobs;
// import uim.platform.identity.provisioning.application.dto;
// import uim.platform.identity.provisioning.domain.entities.provisioning_job;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning;

mixin(ShowModule!());

@safe:
class ProvisioningJobController : HttpController {
  private RunProvisioningJobsUseCase usecase;

  this(RunProvisioningJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/provisioning-jobs", &handleCreate);
    router.get("/api/v1/provisioning-jobs", &handleList);
    router.get("/api/v1/provisioning-jobs/*", &handleGet);
    router.post("/api/v1/provisioning-jobs/run/*", &handleRun);
    router.post("/api/v1/provisioning-jobs/run-now", &handleCreateAndRun);
    router.post("/api/v1/provisioning-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/provisioning-jobs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateProvisioningJobRequest();
      r.tenantId = precheck.tenantId;
      r.sourceSystemId = data.getString("sourceSystemId");
      r.targetSystemId = data.getString("targetSystemId");
      r.jobType = parseJobType(data.getString("jobType"));
      r.schedule = data.getString("schedule");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createJob(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "scheduled");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto items = usecase.listJobs(tenantId);
      auto arr = items.map!(j => j.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto job = usecase.getJob(tenantId, id);
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

  protected void handleRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;

      auto result = usecase.runJob(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleCreate(AndRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateProvisioningJobRequest();
      r.tenantId = precheck.tenantId;
      r.sourceSystemId = data.getString("sourceSystemId");
      r.targetSystemId = data.getString("targetSystemId");
      r.jobType = parseJobType(data.getString("jobType"));
      r.schedule = data.getString("schedule");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createAndRunJob(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.cancelJob(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "cancelled");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deleteJob(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.message == "Provisioning job not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
