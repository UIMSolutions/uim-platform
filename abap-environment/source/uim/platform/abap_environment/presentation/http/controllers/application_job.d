/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.application_job;


// import vibe.http.router;
// import vibe.data.json;
// 
// 
// import uim.platform.abap_environment.application.usecases.manage.application_jobs;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.application_job;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class ApplicationJobController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateApplicationJobRequest r;
      r.tenantId = tenantId;
      r.systemInstanceId = SystemInstanceId(j.getString("systemInstanceId"));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.jobTemplateName = j.getString("jobTemplateName");
      r.frequency = j.getString("frequency");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.cronExpression = j.getString("cronExpression");

      auto result = usecase.createJob(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application job created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

      auto jobs = usecase.listJobs(tenantId, systemId);
      auto arr = jobs.map!(job => job.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", jobs.length)
        .set("message", "Application jobs retrieved successfully");
      
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationJobId(extractIdFromPath(req.requestURI));

      auto job = usecase.getJob(tenantId, id);
      if (job.isNull) {
        writeError(res, 404, "Application job not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("item", job.toJson)
        .set("message", "Application job retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationJobId(extractIdFromPath(req.requestURI));

      auto j = req.json;
      UpdateApplicationJobRequest r;
      r.tenantId = tenantId;
      r.applicationJobId = id;
      r.description = j.getString("description");
      r.frequency = j.getString("frequency");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.cronExpression = j.getString("cronExpression");
      r.active = j.getBoolean("active", true);

      auto result = usecase.updateJob(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "Application job updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationJobId(extractIdFromPath(req.requestURI));
      auto result = usecase.cancelJob(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "canceled")
          .set("message", "Application job canceled successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationJobId(extractIdFromPath(req.requestURI));

      auto result = usecase.deleteJob(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Application job deleted successfully");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
