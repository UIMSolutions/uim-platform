/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.controllers.profile;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.quality.application.usecases.profile_data;
// import uim.platform.data.quality.application.dto;
// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.data_profile;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class ProfileController : PlatformController {
  private ProfileDataUseCase uc;

  this(ProfileDataUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/profiles", &handleProfile);
    router.get("/api/v1/profiles", &handleList);
    router.get("/api/v1/profiles/*", &handleGetById);
  }

  private void handleProfile(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = ProfileDatasetRequest();
      r.tenantId = req.getTenantId;
      r.datasetId = j.getString("datasetId");
      r.datasetName = j.getString("datasetName");

      auto recordsJson = "records" in j;
      if (recordsJson !is null && (recordsJson).isArray) {
        foreach (item; *recordsJson)
        {
          if (item.isObject)
          {
            ProfileRecordInput pri;
            pri.recordId = item.getString("recordId");
            pri.fieldValues = jsonStrMap(item, "fieldValues");
            r.records ~= pri;
          }
        }
      }

      auto profile = uc.profile(r);
      res.writeJsonBody(profile.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto profiles = uc.listByTenant(tenantId);
      auto arr = profiles.map!(p => serializeProfile(p)).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(profiles.length))
          .set("message", "Data profiles retrieved successfully");
          
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
      auto profile = uc.getById(tenantId, id);
      if (profile is null) {
        writeError(res, 404, "Data profile not found");
        return;
      }
      res.writeJsonBody(profile.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeProfile(const DataProfile p) {
    auto j = Json.emptyObject
    .set("id", p.id)
    .set("tenantId", p.tenantId)
    .set("datasetId", p.datasetId)
    .set("datasetName", p.datasetName)
    .set("totalRecords", p.totalRecords)
    .set("profiledRecords", p.profiledRecords)
    .set("overallQualityScore", p.overallQualityScore)
    .set("rating", p.rating.to!string)
    .set("profiledAt", p.profiledAt)
    .set("duration", p.duration);

    auto cols = Json.emptyArray;
    foreach (c; p.columns) {
      auto cj = Json.emptyObject
      .set("fieldName", c.fieldName)
      .set("detectedType", c.detectedType.to!string)
      .set("totalValues", c.totalValues)
      .set("nullCount", c.nullCount)
      .set("emptyCount", c.emptyCount)
      .set("uniqueCount", c.uniqueCount)
      .set("duplicateCount", c.duplicateCount)
      .set("completeness", c.completeness)
      .set("uniqueness", c.uniqueness)
      .set("validity", c.validity)
      .set("minLength", c.minLength)
      .set("maxLength", c.maxLength)
      .set("avgLength", c.avgLength);

      if (c.topValues.length > 0) {
        auto tv = Json.emptyArray;
        foreach (v; c.topValues)
          tv ~= Json(v);
        cj["topValues"] = tv;
      }
      cols ~= cj;
    }
    j["columns"] = cols;

    return j;
  }
}
