/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.application_job;
// import uim.platform.abap_environment.application.usecases.manage.application_jobs;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.application_job;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class ApplicationJobController : ManageController {
  private ManageApplicationJobsUseCase usecase;

  this(ManageApplicationJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/application-jobs", &handleCreate);
    router.get("/api/v1/application-jobs", &handleList);
    router.get("/api/v1/application-jobs/*", &handleGet);
    router.put("/api/v1/application-jobs/*", &handleUpdate);
    router.post("/api/v1/application-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/application-jobs/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto data = precheck.data;
    auto tenantId = precheck.tenantId;
    auto systemId = SystemInstanceId(data.getString("systemInstanceId"));

    auto jobs = usecase.listApplicationJobs(tenantId, systemId);
    auto arr = jobs.map!(job => job.toJson).array.toJson;

    return Json.emptyObject
      .set("items", arr)
      .set("totalCount", jobs.length)
      .set("message", "Application jobs retrieved successfully")
      .set("statusCode", 200);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateApplicationJobRequest r;
    r.tenantId = tenantId;
    r.systemInstanceId = SystemInstanceId(data.getString("systemInstanceId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.jobTemplateName = data.getString("jobTemplateName");
    r.frequency = data.getString("frequency");
    r.scheduledAt = data.getLong("scheduledAt");
    r.cronExpression = data.getString("cronExpression");

    auto result = usecase.createApplicationJob(r);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", result.message)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("message", "Application job created successfully")
      .set("statusCode", 201);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      return precheck;
    }
    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);

    auto job = usecase.getApplicationJob(tenantId, id);
    if (job.isNull) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", "Application job not found")
        .set("statusCode", 404);
    }

    return Json.emptyObject
      .set("item", job.toJson)
      .set("message", "Application job retrieved successfully")
      .set("statusCode", 200);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);
    auto data = req.json;

    UpdateApplicationJobRequest r;
    r.tenantId = tenantId;
    r.applicationJobId = id;
    r.description = data.getString("description");
    r.frequency = data.getString("frequency");
    r.scheduledAt = data.getLong("scheduledAt");
    r.cronExpression = data.getString("cronExpression");
    r.active = data.getBoolean("active", true);

    auto result = usecase.updateApplicationJob(r);
    if (result.hasError()) {
      auto resp = Json.emptyObject
        .set("status", "error")
        .set("message", result.message)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("status", "updated")
      .set("message", "Application job updated successfully")
      .set("statusCode", 200);
  }

  protected void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationJobId(precheck.id);

      auto result = usecase.cancelApplicationJob(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "canceled")
          .set("message", "Application job canceled successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      return precheck;
    }

    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);

    auto result = usecase.deleteApplicationJob(tenantId, id);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", "error")
        .set("message", result.message)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("status", "deleted")
      .set("message", "Application job deleted successfully")
      .set("statusCode", 200);
  }
}