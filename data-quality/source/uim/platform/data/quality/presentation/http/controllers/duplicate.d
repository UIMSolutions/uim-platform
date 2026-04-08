/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data - quality.presentation.http.controllers.duplicate;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.data.quality.application.usecases.detect_duplicates;
import uim.platform.data.quality.application.dto;
import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.match_group;
import uim.platform.data.quality.domain.services.duplicate_detector : RecordEntry;

class DuplicateController : SAPController {
  private DetectDuplicatesUseCase uc;

  this(DetectDuplicatesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/duplicates/detect", &handleDetect);
    router.post("/api/v1/duplicates/resolve", &handleResolve);
    router.get("/api/v1/duplicates", &handleList);
    router.get("/api/v1/duplicates/*", &handleGetById);
  }

  private void handleDetect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = DetectDuplicatesRequest();
      r.tenantId = req.getTenantId;
      r.datasetId = j.getString("datasetId");
      r.matchFields = jsonStrArrayArray(j, "matchFields");
      r.strategy = parseStrategy(j.getString("strategy"));
      r.threshold = jsonDouble(j, "threshold", 70.0);

      auto recordsJson = "records" in j;
      if (recordsJson !is null && (*recordsJson).type == Json.Type.array) {
        foreach (item; *recordsJson)
        {
          if (item.type == Json.Type.object)
          {
            DuplicateRecordInput dri;
            dri.recordId = item.getString("recordId");
            dri.fieldValues = jsonStrMap(item, "fieldValues");
            r.records ~= dri;
          }
        }
      }

      auto groups = uc.detect(r);
      auto arr = Json.emptyArray;
      foreach (ref g; groups)
        arr ~= serializeGroup(g);

      auto resp = Json.emptyObject;
      resp["matchGroups"] = arr;
      resp["totalGroups"] = Json(cast(long) groups.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = ResolveDuplicateRequest();
      r.tenantId = req.getTenantId;
      r.groupId = j.getString("groupId");
      r.survivorRecordId = j.getString("survivorRecordId");

      auto result = uc.resolve(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["resolved"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto groups = uc.getUnresolved(tenantId);
      auto arr = Json.emptyArray;
      foreach (ref g; groups)
        arr ~= serializeGroup(g);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) groups.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto group = uc.getById(id, tenantId);
      if (group is null) {
        writeError(res, 404, "Match group not found");
        return;
      }
      res.writeJsonBody(serializeGroup(*group), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeGroup(ref const MatchGroup g) {
    auto j = Json.emptyObject;
    j["id"] = Json(g.id);
    j["tenantId"] = Json(g.tenantId);
    j["datasetId"] = Json(g.datasetId);
    j["strategy"] = Json(g.strategy.to!string);
    j["survivorRecordId"] = Json(g.survivorRecordId);
    j["resolved"] = Json(g.resolved);
    j["detectedAt"] = Json(g.detectedAt);

    auto candidates = Json.emptyArray;
    foreach (ref c; g.candidates) {
      auto cj = Json.emptyObject;
      cj["recordId"] = Json(c.recordId);
      cj["score"] = Json(c.score);
      cj["confidence"] = Json(c.confidence.to!string);
      cj["isSurvivor"] = Json(c.isSurvivor);
      candidates ~= cj;
    }
    j["candidates"] = candidates;

    return j;
  }

  private static MatchStrategy parseStrategy(string s) {
    switch (s) {
    case "exact":
      return MatchStrategy.exact;
    case "fuzzy":
      return MatchStrategy.fuzzy;
    case "phonetic":
      return MatchStrategy.phonetic;
    case "composite":
      return MatchStrategy.composite;
    default:
      return MatchStrategy.fuzzy;
    }
  }
}
