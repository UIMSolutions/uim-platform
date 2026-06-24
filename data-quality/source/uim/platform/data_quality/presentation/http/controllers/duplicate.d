/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.duplicate;

import uim.platform.service;
import uim.platform.data_quality;

// mixin(ShowModule!());

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

  protected Json detectHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

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

    auto groups = usecase.detect(r).map!(g => g.toJson).array.toJson;
    auto resp = Json.emptyObject
      .set("matchGroups", groups)
      .set("totalGroups", groups.length);

    return successResponse("Duplicate groups detected successfully", "Detected", 200, resp);
  }

  mixin(HandleTemplate!("handleDetect", "detectHandler"));

  protected Json resolveHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = ResolveDuplicateRequest();
    r.tenantId = tenantId;
    r.groupId = data.getString("groupId");
    r.survivorRecordId = data.getString("survivorRecordId");

    auto result = usecase.resolve(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("resolved", true);

    return successResponse("Duplicate group resolved successfully", "Resolved", 200, resp);
  }

  mixin(HandleTemplate!("handleResolve", "resolveHandler"));

  protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto groups = usecase.getUnresolved(tenantId);
    auto arr = groups.map!(g => g.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", groups.length)
      .set("resources", arr);
      
    return successResponse("Duplicate groups retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto group = usecase.getById(tenantId, id);
    if (group.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = group.toJson();
    return successResponse("Duplicate group retrieved successfully", "Retrieved", 200, responseData);
  }
}
