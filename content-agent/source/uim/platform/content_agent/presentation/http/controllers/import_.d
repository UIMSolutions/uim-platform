/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.import_;

// import uim.platform.content_agent.application.usecases.import_content;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.import_job;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class ImportController : HttpController {
  private ImportContentUseCase usecase;

  this(ImportContentUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/imports", &handleStartImport);
    router.get("/api/v1/imports", &handleList);
    router.get("/api/v1/imports/*", &handleGet);
  }

  protected void handleStartImport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = StartImportRequest();
      r.tenantId = precheck.tenantId;
      r.packageId = ContentPackageId(data.getString("packageId"));
      r.transportRequestId = TransportRequestId(data.getString("transportRequestId"));
      r.sourceFilePath = data.getString("sourceFilePath");
      r.startedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.startImport(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "completed")
          .set("message", "Import started successfully");

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
      auto jobs = usecase.listImportJobs(tenantId);

      auto arr = jobs.map!(j => j.toJson).array.toJson;

      auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = ImportJobId(precheck.id);
      auto job = usecase.getImportJob(tenantId, id);
      if (job.isNull) {
        writeError(res, 404, "Import job not found");
        return;
      }
      res.writeJsonBody(job.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
