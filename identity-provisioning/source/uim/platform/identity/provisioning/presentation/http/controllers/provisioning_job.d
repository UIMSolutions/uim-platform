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

// mixin(ShowModule!());

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
    r.tenantId = tenantId;
    r.sourceSystemId = data.getString("sourceSystemId");
    r.targetSystemId = data.getString("targetSystemId");
    r.jobType = toJobType(data.getString("jobType"));
    r.schedule = data.getString("schedule");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createJob(r);
    if (result.isSuccess) {
      auto resp = Json.emptyObject
        .set("id", result.id);

      return successResponse("Provisioning job created successfully", 201, resp);
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

      return successResponse("Provisioning jobs retrieved successfully", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
      auto precheck = super.getHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto id = ProvisioningJobId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid provisioning job ID", 400);

      auto job = usecase.getJob(tenantId, id);
      if (job.isNull)
        return errorResponse("Provisioning job not found", 404);

      auto resp = job.toJson;
      return successResponse("Provisioning job retrieved successfully", 200, resp);
    }

    protected Json runHandler(HTTPServerRequest req) {
      auto precheck = super.postHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto id = ProvisioningJobId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid provisioning job ID", 400);

      auto result = usecase.runJob(tenantId, id);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("status", "running");
      return successResponse("Provisioning job started successfully", 200, resp);
    }

    protected void handleRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto response = runHandler(req);
        res.writeJsonBody(response, response.code);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    protected Json createAndRunHandler(HTTPServerRequest req) {
      auto createResponse = super.postHandler(req);
      if (createResponse.hasError)
        return createResponse;

      auto id = createResponse.data.getString("id");
      if (id is null)
        return errorResponse("Failed to retrieve created job ID", 500);

      auto runResponse = runHandler(req);
      if (runResponse.hasError)
        return runResponse;

      auto resp = Json.emptyObject
        .set("id", id)
        .set("status", "running");
      return successResponse("Provisioning job created and started successfully", 201, resp);
    }

    protected void handleCreateAndRun(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto response = createAndRunHandler(req);
        res.writeJsonBody(response, response.code);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    protected Json cancelHandler(HTTPServerRequest req) {
      auto precheck = super.postHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto id = ProvisioningJobId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid provisioning job ID", 400);

      auto result = usecase.cancelJob(tenantId, id);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto resp = Json.emptyObject
        .set("id", result.id);
      return successResponse("Provisioning job cancelled successfully", 200, resp);
    }

    protected void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto response = cancelHandler(req);
        res.writeJsonBody(response, response.code);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
      auto precheck = super.deleteHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto id = ProvisioningJobId(precheck.id);
      if (id.isNull) // This should ideally never happen since the route requires an ID, but we check just in case
        return errorResponse("Invalid provisioning job ID", 400);

      auto result = usecase.deleteJob(tenantId, id);
      if (result.hasError)

        auto resp = Json.emptyObject.set("id", result.id);
      return successResponse("Provisioning job deleted successfully", 200, resp);
    }
  }
