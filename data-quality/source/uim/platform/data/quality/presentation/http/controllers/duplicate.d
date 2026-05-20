/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.controllers.duplicate;
// import uim.platform.data.quality.application.usecases.detect_duplicates;
// import uim.platform.data.quality.application.dto;
// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.match_group;
// import uim.platform.data.quality.domain.services.duplicate_detector : RecordEntry;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class DuplicateController : PlatformController {
  private DetectDuplicatesUseCase usecase;

  this(DetectDuplicatesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/duplicates/detect", &handleDetect);
    router.post("/api/v1/duplicates/resolve", &handleResolve);
    router.get("/api/v1/duplicates", &handleList);
    router.get("/api/v1/duplicates/*", &handleGet);
  }

  protected void handleDetect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      auto r = DetectDuplicatesRequest();
      r.tenantId = tenantId;
      r.datasetId = DataSetId(j.getString("datasetId"));
      r.matchFields = j.getStringsArray("matchFields");
      r.strategy = j.getString("strategy").to!MatchStrategy;
      r.threshold = j.getDouble("threshold", 70.0);

      foreach (item; j.getArray("records")) {
        if (item.isObject) {
          DuplicateRecordInput dri;
          dri.recordId = item.getString("recordId");
          dri.fieldValues = item.getArray("fieldValues").map!(v => v.to!string).array;
          r.records ~= dri;
        }
      }

      auto groups = usecase.detect(r);
      auto arr = groups.map!(g => g.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("matchGroups", arr)
        .set("totalGroups", Json(groups.length))
        .set("message", "Duplicate groups detected successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      auto r = ResolveDuplicateRequest();
      r.tenantId = tenantId;
      r.groupId = j.getString("groupId");
      r.survivorRecordId = j.getString("survivorRecordId");

      auto result = usecase.resolve(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("resolved", true)
          .set("message", "Duplicate group resolved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto groups = usecase.getUnresolved(tenantId);
      auto arr = groups.map!(g => g.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", groups.length)
        .set("message", "Duplicate groups retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto group = usecase.getById(tenantId, id);
      if (group.isNull) {
        writeError(res, 404, "Match group not found");
        return;
      }
      res.writeJsonBody(group.toJson, 200);
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
