/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.log;
// import uim.platform.logging.application.usecases.ingest_logs;


import uim.platform.logging;

// mixin(ShowModule!());

@safe:

class LogController : HttpController {
  private IngestLogsUseCase usecase;

  this(IngestLogsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/logs", &handleIngest);
    router.post("/api/v1/logs/batch", &handleBatchIngest);
  }

  protected Json ingestHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    IngestLogRequest r;
    r.tenantId = tenantId;
    r.streamId = data.getString("streamId");
    r.level = data.getString("level");
    r.source = data.getString("source");
    r.message = data.getString("message");
    r.structuredData = data.jsonStrMap("structuredData");
    r.traceId = data.getString("traceId");
    r.spanId = data.getString("spanId");
    r.requestId = data.getString("requestId");
    r.correlationId = data.getString("correlationId");
    r.componentName = data.getString("componentName");
    r.spaceName = data.getString("spaceName");
    r.orgName = data.getString("orgName");
    r.resourceType = data.getString("resourceType");
    r.resourceId = data.getString("resourceId");
    r.tags = data.getStrings("tags");

    auto result = usecase.ingest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);
    return successResponse("Log ingested successfully", "Created", 201, resp);
  }

  protected void handleIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = ingestHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json batchIngestHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    IngestLogBatchRequest batchReq;
    batchReq.tenantId = tenantId;

    foreach (ej; data.getArray("entries")) {
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
      r.spaceName = getString(ej, "spaceName");
      r.orgName = getString(ej, "orgName");
      r.resourceType = getString(ej, "resourceType");
      r.resourceId = getString(ej, "resourceId");
      r.tags = getStrings(ej, "tags");
      batchReq.entries ~= r;
    }

    auto result = usecase.ingestBatch(batchReq);
    auto resp = Json.emptyObject
      .set("success", result.success)
      .set("message", result.message);

    return successResponse("Batch log ingestion completed", 200, resp);
  }
  protected void handleBatchIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = batchIngestHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
