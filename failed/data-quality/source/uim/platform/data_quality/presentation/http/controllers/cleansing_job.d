/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.cleansing_job;

import uim.platform.data_quality.application.usecases.manage.cleansing_jobs;
import uim.platform.data_quality.domain.entities.cleansing_job;
import uim.platform.service;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class CleansingJobController : ManageHttpController {
  private ManageCleansingJobsUseCase usecase;

  this(ManageCleansingJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cleansing-jobs", &handleCreate);
    router.get("/api/v1/cleansing-jobs", &handleList);
    router.get("/api/v1/cleansing-jobs/*", &handleGet);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateCleansingJobRequest();
    r.tenantId = tenantId;
    r.datasetId = data.getString("datasetId");
    r.requestedBy = data.getString("requestedBy");
    r.ruleIds = data.getStrings("ruleIds");

    auto result = usecase.createCleansingJob(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
      
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", "pending");

    return successResponse("Cleansing job created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto jobs = usecase.listCleansingJobs(tenantId);
    auto arr = jobs.map!(j => j.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(jobs.length));
    return successResponse("Cleansing jobs retrieved successfully", 0, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CleansingJobId(precheck.id);

    auto job = usecase.getCleansingJob(tenantId, id);
    if (job.isNull)
      return errorResponse("Cleansing job not found", 404);

    return successResponse("Cleansing job retrieved successfully", 200, job.toJson);
  }

}
