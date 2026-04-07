/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.trace;

import uim.platform.logging.application.usecases.ingest_traces;
import uim.platform.logging.application.dto;
import uim.platform.logging.domain.entities.span;
import uim.platform.logging.domain.types;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class TraceController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.traceId = jsonStr(j, "traceId");
      r.parentSpanId = jsonStr(j, "parentSpanId");
      r.operationName = jsonStr(j, "operationName");
      r.serviceName = jsonStr(j, "serviceName");
      r.startTime = jsonLong(j, "startTime");
      r.endTime = jsonLong(j, "endTime");
      r.status = jsonStr(j, "status");
      r.kind = jsonStr(j, "kind");
      r.attributes = jsonStrMap(j, "attributes");
      r.resourceAttributes = jsonStrMap(j, "resourceAttributes");

      auto result = uc.ingestSpan(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleBatchIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto tenantId = req.headers.get("X-Tenant-Id", "");

      IngestSpanBatchRequest batchReq;
      batchReq.tenantId = tenantId;

      auto spansVal = "spans" in j;
      if (spansVal !is null && (*spansVal).type == Json.Type.array) {
        foreach (sj; *spansVal) {
          IngestSpanRequest r;
          r.tenantId = tenantId;
          r.traceId = jsonStr(sj, "traceId");
          r.parentSpanId = jsonStr(sj, "parentSpanId");
          r.operationName = jsonStr(sj, "operationName");
          r.serviceName = jsonStr(sj, "serviceName");
          r.startTime = jsonLong(sj, "startTime");
          r.endTime = jsonLong(sj, "endTime");
          r.status = jsonStr(sj, "status");
          r.kind = jsonStr(sj, "kind");
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

      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto traceId = extractIdFromPath(req.requestURI.to!string);

      auto spans = uc.getTrace(tenantId, traceId);

      auto jarr = Json.emptyArray;
      foreach (ref s; spans) {
        auto sj = Json.emptyObject;
        sj["id"] = Json(s.id);
        sj["traceId"] = Json(s.traceId);
        sj["parentSpanId"] = Json(s.parentSpanId);
        sj["operationName"] = Json(s.operationName);
        sj["serviceName"] = Json(s.serviceName);
        sj["startTime"] = Json(s.startTime);
        sj["endTime"] = Json(s.endTime);
        sj["durationMs"] = Json(s.durationMs);
        jarr ~= sj;
      }

      auto resp = Json.emptyObject;
      resp["traceId"] = Json(traceId);
      resp["spans"] = jarr;
      resp["totalSpans"] = Json(cast(long) spans.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
