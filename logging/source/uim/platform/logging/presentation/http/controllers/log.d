/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.log;
// import uim.platform.logging.application.usecases.ingest_logs;
// import uim.platform.logging.application.dto;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class LogController : PlatformController {
  private IngestLogsUseCase usecase;

  this(IngestLogsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/logs", &handleIngest);
    router.post("/api/v1/logs/batch", &handleBatchIngest);
  }

  protected void handleIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      IngestLogRequest r;
      r.tenantId = tenantId;
      r.streamId = j.getString("streamId");
      r.level = j.getString("level");
      r.source = j.getString("source");
      r.message = j.getString("message");
      r.structuredData = jsonStrMap(j, "structuredData");
      r.traceId = j.getString("traceId");
      r.spanId = j.getString("spanId");
      r.requestId = j.getString("requestId");
      r.correlationId = j.getString("correlationId");
      r.componentName = j.getString("componentName");
      r.spaceName = j.getString("spaceName");
      r.orgName = j.getString("orgName");
      r.resourceType = j.getString("resourceType");
      r.resourceId = j.getString("resourceId");
      r.tags = getStrings(j, "tags");

      auto result = usecase.ingest(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleBatchIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      IngestLogBatchRequest batchReq;
      batchReq.tenantId = tenantId;

      foreach (ej; j.getArray("entries")) {
        IngestLogRequest r;
        r.tenantId = tenantId;
        r.streamId = getString(ej, "streamId");
        r.level = getString(ej, "level");
        r.source = getString(ej, "source");
        r.message = getString(ej, "message");
        r.structuredData = jsonStrMap(ej, "structuredData");
        r.traceId = getString(ej, "traceId");
        r.spanId = getString(ej, "spanId");
        r.requestId = getString(ej, "requestId");
        r.correlationId = getString(ej, "correlationId");
        r.componentName = getString(ej, "componentName");
        r.tags = getStrings(ej, "tags");
        batchReq.entries ~= r;
      }

      auto result = usecase.ingestBatch(batchReq);
      auto resp = Json.emptyObject
        .set("success", result.success)
        .set("message", result.message);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
