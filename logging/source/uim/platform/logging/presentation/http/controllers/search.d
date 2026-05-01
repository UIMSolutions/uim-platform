/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.search;

// import uim.platform.logging.application.usecases.search_logs;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.services.log_parser;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class SearchController : PlatformController {
  private SearchLogsUseCase uc;

  this(SearchLogsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/search", &handleSearch);
    router.get("/api/v1/logs/*", &handleGetById);
  }

  private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      SearchLogsRequest r;
      r.tenantId = req.getTenantId;
      r.query = req.params.get("q", "");
      r.level = req.params.get("level", "");
      r.streamId = req.params.get("streamId", "");
      r.traceId = req.params.get("traceId", "");
      r.correlationId = req.params.get("correlationId", "");

      auto startStr = req.params.get("startTime", "");
      if (startStr.length > 0) {
        try
          r.startTime = startStr.to!long;
        catch (Exception) {
        }
      }
      auto endStr = req.params.get("endTime", "");
      if (endStr.length > 0) {
        try
          r.endTime = endStr.to!long;
        catch (Exception) {
        }
      }

      auto entries = uc.search(r);

      auto jarr = Json.emptyArray;
      foreach (e; entries) {
        jarr ~= Json.emptyObject
          .set("id", e.id)
          .set("timestamp", e.timestamp)
          .set("level", LogParser.levelToString(e.level))
          .set("source", e.source)
          .set("message", e.message)
          .set("traceId", e.traceId)
          .set("spanId", e.spanId)
          .set("correlationId", e.correlationId)
          .set("componentName", e.componentName)
          .set("streamId", e.streamId);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", entries.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto entry = uc.getById(id);

      if (entry.isNull) {
        writeError(res, 404, "Log entry not found");
        return;
      }

      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("tenantId", entry.tenantId)
        .set("streamId", entry.streamId)
        .set("timestamp", entry.timestamp)
        .set("level", LogParser.levelToString(entry.level))
        .set("source", entry.source)
        .set("message", entry.message)
        .set("traceId", entry.traceId)
        .set("spanId", entry.spanId)
        .set("requestId", entry.requestId)
        .set("correlationId", entry.correlationId)
        .set("componentName", entry.componentName)
        .set("spaceName", entry.spaceName)
        .set("orgName", entry.orgName)
        .set("resourceType", entry.resourceType)
        .set("resourceId", entry.resourceId)
        .set("tags", toJsonArray(entry.tags));

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
