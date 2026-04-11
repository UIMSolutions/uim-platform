/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.search;

import uim.platform.logging.application.usecases.search_logs;
import uim.platform.logging.application.dto;
import uim.platform.logging.domain.entities.log_entry;
import uim.platform.logging.domain.services.log_parser;
import uim.platform.logging.domain.types;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

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
        auto ej = Json.emptyObject;
        ej["id"] = Json(e.id);
        ej["timestamp"] = Json(e.timestamp);
        ej["level"] = Json(LogParser.levelToString(e.level));
        ej["source"] = Json(e.source);
        ej["message"] = Json(e.message);
        ej["traceId"] = Json(e.traceId);
        ej["spanId"] = Json(e.spanId);
        ej["correlationId"] = Json(e.correlationId);
        ej["componentName"] = Json(e.componentName);
        ej["streamId"] = Json(e.streamId);
        jarr ~= ej;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) entries.length);
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

      if (entry.id.isEmpty) {
        writeError(res, 404, "Log entry not found");
        return;
      }

      auto ej = Json.emptyObject;
      ej["id"] = Json(entry.id);
      ej["tenantId"] = Json(entry.tenantId);
      ej["streamId"] = Json(entry.streamId);
      ej["timestamp"] = Json(entry.timestamp);
      ej["level"] = Json(LogParser.levelToString(entry.level));
      ej["source"] = Json(entry.source);
      ej["message"] = Json(entry.message);
      ej["traceId"] = Json(entry.traceId);
      ej["spanId"] = Json(entry.spanId);
      ej["requestId"] = Json(entry.requestId);
      ej["correlationId"] = Json(entry.correlationId);
      ej["componentName"] = Json(entry.componentName);
      ej["spaceName"] = Json(entry.spaceName);
      ej["orgName"] = Json(entry.orgName);
      ej["resourceType"] = Json(entry.resourceType);
      ej["resourceId"] = Json(entry.resourceId);
      ej["tags"] = toJsonArray(entry.tags);

      res.writeJsonBody(ej, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
