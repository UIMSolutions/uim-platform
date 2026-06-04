/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.trace;
// import uim.platform.logging.application.usecases.ingest_traces;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.span;


import uim.platform.logging;

mixin(ShowModule!());

@safe:

class TraceController : PlatformController {
  private IngestTracesUseCase usecase;

  this(IngestTracesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/traces/spans", &handleIngestSpan);
    router.post("/api/v1/traces/spans/batch", &handleBatchIngest);
    router.get("/api/v1/traces/*", &handleTrace);
  }

  protected Json ingestSpanHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    IngestSpanRequest r;
    r.tenantId = tenantId;
    r.traceId = data.getString("traceId");
    r.parentSpanId = data.getString("parentSpanId");
    r.operationName = data.getString("operationName");
    r.serviceName = data.getString("serviceName");
    r.startTime = data.getLong("startTime");
    r.endTime = data.getLong("endTime");
    r.status = data.getString("status");
    r.kind = data.getString("kind");
    r.attributes = data.jsonStrMap("attributes");
    r.resourceAttributes = data.jsonStrMap("resourceAttributes");

    auto result = usecase.ingestSpan(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);
    return successResponse("Span ingested successfully", "Created", 201, resp);
  }

  protected void handleIngestSpan(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = ingestSpanHandler(req);
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
    IngestSpanBatchRequest batchReq;
    batchReq.tenantId = tenantId;

    foreach (sj; data.getArray("spans")) {
      IngestSpanRequest r;
      r.tenantId = tenantId;
      r.traceId = getString(sj, "traceId");
      r.parentSpanId = getString(sj, "parentSpanId");
      r.operationName = getString(sj, "operationName");
      r.serviceName = getString(sj, "serviceName");
      r.startTime = jsonLong(sj, "startTime");
      r.endTime = jsonLong(sj, "endTime");
      r.status = getString(sj, "status");
      r.kind = getString(sj, "kind");
      r.attributes = jsonStrMap(sj, "attributes");
      r.resourceAttributes = jsonStrMap(sj, "resourceAttributes");
      batchReq.spans ~= r;
    }

    auto result = usecase.ingestSpanBatch(batchReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Batch span ingest completed successfully", "Created", 201, resp);
  }

  protected void handleBatchIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = batchIngestHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json traceHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto traceId = TraceId(precheck.id);
    if (traceId.isNull)
      return errorResponse("Invalid trace ID", "Bad Request", 400);

    auto spans = usecase.getTrace(tenantId, traceId);
    auto list = Json.emptyArray;
    foreach (s; spans) {
      list ~= Json.emptyObject
        .set("id", s.id)
        .set("traceId", s.traceId)
        .set("parentSpanId", s.parentSpanId)
        .set("operationName", s.operationName)
        .set("serviceName", s.serviceName)
        .set("startTime", s.startTime)
        .set("endTime", s.endTime)
        .set("durationMs", s.durationMs);
    }

    auto response = Json.emptyObject
      .set("traceId", traceId.value)
      .set("spans", list)
      .set("totalSpans", Json(spans.length));

    return successResponse("Trace retrieved successfully", "Retrieved", 200, response);
  }
}
