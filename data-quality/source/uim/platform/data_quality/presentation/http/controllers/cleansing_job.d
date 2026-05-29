/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.cleansing_job;

// import uim.platform.data_quality.application.usecases.manage.cleansing_jobs;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.cleansing_job;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class CleansingJobController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateCleansingJobRequest();
      r.tenantId = tenantId;
      r.datasetId = data.getString("datasetId");
      r.requestedBy = data.getString("requestedBy");
      r.ruleIds = data.getStrings("ruleIds");

      auto result = usecase.createCleansingJob(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", "pending")
            .set("message", "Cleansing job created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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
            .set("totalCount", Json(jobs.length))
            .set("message", "Cleansing jobs retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = CleansingJobId(precheck.id);

      auto job = usecase.getCleansingJob(tenantId, id);
      if (job.isNull) {
        writeError(res, 404, "Cleansing job not found");
        return;
      }
      res.writeJsonBody(job.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
