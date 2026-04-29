/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.controllers.duplicate;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.quality.application.usecases.detect_duplicates;
// import uim.platform.data.quality.application.dto;
// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.match_group;
// import uim.platform.data.quality.domain.services.duplicate_detector : RecordEntry;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class DuplicateController : PlatformController {
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
      r.matchFields = getStringArrayArray(j, "matchFields");
      r.strategy = parseStrategy(j.getString("strategy"));
      r.threshold = getDouble(j, "threshold", 70.0);

      auto recordsJson = "records" in j;
      if (recordsJson !is null && (*recordsJson).isArray) {
        foreach (item; *recordsJson) {
          if (item.isObject) {
            DuplicateRecordInput dri;
            dri.recordId = item.getString("recordId");
            dri.fieldValues = jsonStrMap(item, "fieldValues");
            r.records ~= dri;
          }
        }
      }

      auto groups = uc.detect(r);
      auto arr = Json.emptyArray;
      foreach (g; groups)
        arr ~= serializeGroup(g);

      auto resp = Json.emptyObject
          .set("matchGroups", arr)
          .set("totalGroups", Json(groups.length))
          .set("message", "Duplicate groups detected successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
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
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("resolved", Json(true))
            .set("message", "Duplicate group resolved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto groups = uc.getUnresolved(tenantId);
      auto arr = Json.emptyArray;
      foreach (g; groups)
        arr ~= serializeGroup(g);

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(groups.length))
            .set("message", "Duplicate groups retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto group = uc.getById(tenantId, id);
      if (group is null) {
        writeError(res, 404, "Match group not found");
        return;
      }
      res.writeJsonBody(serializeGroup(*group), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeGroup(const MatchGroup g) {
    auto json = Json.emptyObject
      .set("id", g.id)
      .set("tenantId", g.tenantId)
      .set("datasetId", g.datasetId)
      .set("strategy", g.strategy.to!string)
      .set("survivorRecordId", g.survivorRecordId)
      .set("resolved", g.resolved)
      .set("detectedAt", g.detectedAt);

    auto candidates = Json.emptyArray;
    foreach (c; g.candidates) {
      candidates ~= Json.emptyObject
      .set("recordId", c.recordId)
      .set("score", c.score)
      .set("confidence", c.confidence.to!string)
      .set("isSurvivor", c.isSurvivor);
    }
    json["candidates"] = candidates;

    return json;
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
