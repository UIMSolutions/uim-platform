/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.log;

import uim.platform.logging.application.usecases.ingest_logs;
import uim.platform.logging.application.dto;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class LogController : SAPController {
  private IngestLogsUseCase uc;

  this(IngestLogsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/logs", &handleIngest);
    router.post("/api/v1/logs/batch", &handleBatchIngest);
  }

  private void handleIngest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      IngestLogRequest r;
      r.tenantId = req.getTenantId;
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
      r.tags = jsonStrArray(j, "tags");

      auto result = uc.ingest(r);
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
      auto tenantId = req.getTenantId;

      IngestLogBatchRequest batchReq;
      batchReq.tenantId = tenantId;

      auto entriesVal = "entries" in j;
      if (entriesVal !is null && (*entriesVal).type == Json.Type.array) {
        foreach (ej; *entriesVal) {
          IngestLogRequest r;
          r.tenantId = tenantId;
          r.streamId = jsonStr(ej, "streamId");
          r.level = jsonStr(ej, "level");
          r.source = jsonStr(ej, "source");
          r.message = jsonStr(ej, "message");
          r.structuredData = jsonStrMap(ej, "structuredData");
          r.traceId = jsonStr(ej, "traceId");
          r.spanId = jsonStr(ej, "spanId");
          r.requestId = jsonStr(ej, "requestId");
          r.correlationId = jsonStr(ej, "correlationId");
          r.componentName = jsonStr(ej, "componentName");
          r.tags = jsonStrArray(ej, "tags");
          batchReq.entries ~= r;
        }
      }

      auto result = uc.ingestBatch(batchReq);
      auto resp = Json.emptyObject;
      resp["success"] = Json(result.success);
      resp["message"] = Json(result.error);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
