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


import uim.platform.logging;

mixin(ShowModule!());

@safe:

class SearchController : HttpController {
  private SearchLogsUseCase usecase;

  this(SearchLogsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/search", &handleSearch);
    router.get("/api/v1/logs/*", &handleGet);
  }

  protected Json searchHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    SearchLogsRequest r;
    r.tenantId = precheck.tenantId;
    r.query = req.params.get("q", "");
    r.level = req.params.get("level", "");
    r.streamId = LogStreamId(req.params.get("streamId", ""));
    r.traceId = TraceId(req.params.get("traceId", ""));
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

    auto entries = usecase.searchLogs(r);

    auto list = Json.emptyArray;
    foreach (e; entries) {
      list ~= Json.emptyObject
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

    auto responseData = Json.emptyObject
      .set("items", list)
      .set("totalCount", entries.length);

    return successResponse("Search completed successfully", "Retrieved", 200, responseData);
  }

  protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = searchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = LogEntryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid log entry ID", "Bad Request", 400);

    auto entry = usecase.getLog(tenantId, id);
    if (entry.isNull)
      return errorResponse("Log entry not found", "Not Found", 404);

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
      .set("tags", entry.tags.toJson);

    return successResponse("Log entry retrieved successfully", "Retrieved", 200, response);
  }
}
