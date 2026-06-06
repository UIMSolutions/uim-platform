/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.duplicate;
// import uim.platform.data_quality.application.usecases.detect_duplicates;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.match_group;
// import uim.platform.data_quality.domain.services.duplicate_detector : RecordEntry;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class DuplicateController : HttpController {
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
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = DetectDuplicatesRequest();
      r.tenantId = tenantId;
      r.datasetId = DataSetId(data.getString("datasetId"));
      r.matchFields = j.getStringsArray("matchFields");
      r.strategy = data.getString("strategy").to!MatchStrategy;
      r.threshold = data.getDouble("threshold", 70.0);

      foreach (item; data.getArray("records")) {
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
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = ResolveDuplicateRequest();
      r.tenantId = tenantId;
      r.groupId = data.getString("groupId");
      r.survivorRecordId = data.getString("survivorRecordId");

      auto result = usecase.resolve(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("resolved", true)
          .set("message", "Duplicate group resolved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto groups = usecase.getUnresolved(tenantId);
    auto arr = groups.map!(g => g.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Duplicate groups retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    auto group = usecase.getById(tenantId, id);
    if (group.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = group.toJson();
    return successResponse("Duplicate group retrieved successfully", "Retrieved", 200, responseData);
  }
}
