/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.trace;

// import uim.platform.logging.application.usecases.ingest_traces;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.span;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class TraceController : PlatformController {
  private IngestTracesUseCase uc;

  this(IngestTracesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/traces/spans", &handleIngestSpan);
    router.post("/api/v1/traces/spans/batch", &handleBatchIngest);
    router.get("/api/v1/traces/*", &handleGetTrace);
  }

  private void handleIngestSpan(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      IngestSpanRequest r;
      r.tenantId = req.getTenantId;
      r.traceId = j.getString("traceId");
      r.parentSpanId = j.getString("parentSpanId");
      r.operationName = j.getString("operationName");
      r.serviceName = j.getString("serviceName");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");
      r.status = j.getString("status");
      r.kind = j.getString("kind");
      r.attributes = jsonStrMap(j, "attributes");
      r.resourceAttributes = jsonStrMap(j, "resourceAttributes");

      auto result = uc.ingestSpan(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleBatchIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      TenantId tenantId = req.getTenantId;

      IngestSpanBatchRequest batchReq;
      batchReq.tenantId = tenantId;

      auto spansVal = "spans" in j;
      if (spansVal !is null && (*spansVal).isArray) {
        foreach (sj; *spansVal) {
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
      }

      auto result = uc.ingestSpanBatch(batchReq);
      auto resp = Json.emptyObject;
      resp["success"] = Json(result.success);
      resp["message"] = Json(result.error);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetTrace(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      TenantId tenantId = req.getTenantId;
      auto traceId = extractIdFromPath(req.requestURI.to!string);

      auto spans = uc.getTrace(tenantId, traceId);

      auto jarr = Json.emptyArray;
      foreach (s; spans) {
        jarr ~= Json.emptyObject
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
        .set("traceId", Json(traceId))
        .set("spans", jarr)
        .set("totalSpans", Json(spans.length));
        
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
