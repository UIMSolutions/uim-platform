/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.change_log;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.master_data_integration.application.usecases.query_change_log;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.change_log_entry;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class ChangeLogController : PlatformController {
  private QueryChangeLogUseCase uc;

  this(QueryChangeLogUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/change-log", &handleQuery);
    router.get("/api/v1/change-log/*", &handleGetById);
  }

  private void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ChangeLogQueryRequest r;
      r.tenantId = req.getTenantId;
      r.objectId = req.params.get("objectId", "");
      r.category = req.params.get("category", "");
      r.deltaToken = req.params.get("deltaToken", "");

      auto sinceStr = req.params.get("since", "");
      if (sinceStr.length > 0) {
        // import std.conv : to;
        try
          r.sinceTimestamp = sinceStr.to!long;
        catch (Exception) {
        }
      }

      auto entries = uc.query(r);

      auto arr = Json.emptyArray;
      foreach (e; entries)
        arr ~= serializeEntry(e);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(entries.length));

      // Provide the last delta token for incremental polling
      if (entries.length > 0)
        resp["nextDeltaToken"] = Json(entries[$ - 1].deltaToken);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto entry = uc.getEntry(id);
      if (entry.isNull) {
        writeError(res, 404, "Change log entry not found");
        return;
      }
      res.writeJsonBody(serializeEntry(entry), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeEntry(ChangeLogEntry e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("objectId", e.objectId)
      .set("dataModelId", e.dataModelId)
      .set("category", e.category.to!string)
      .set("changeType", e.changeType.to!string)
      .set("objectType", e.objectType)
      .set("changedFields", e.changedFields)
      .set("oldValues", e.oldValues)
      .set("newValues", e.newValues)
      .set("sourceSystem", e.sourceSystem)
      .set("sourceClient", e.sourceClient)
      .set("changedBy", e.changedBy)
      .set("fromVersion", e.fromVersion)
      .set("toVersion", e.toVersion)
      .set("deltaToken", e.deltaToken)
      .set("timestamp", e.timestamp);
  }
}
