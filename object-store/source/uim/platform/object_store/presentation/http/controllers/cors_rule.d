/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.cors_rule;

// import uim.platform.object_store.application.usecases.manage.cors_rules;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.cors_rule;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

class CorsRuleController : ManageController {
  private ManageCorsRulesUseCase usecase;

  this(ManageCorsRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cors-rules", &handleCreate);
    router.get("/api/v1/buckets/*/cors-rules", &handleListByBucket);
    router.get("/api/v1/cors-rules/*", &handleGet);
    router.put("/api/v1/cors-rules/*", &handleUpdate);
    router.delete_("/api/v1/cors-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto r = CreateCorsRuleRequest();
    r.tenantId = tenantId;
    r.bucketId = data.getString("bucketId");
    r.allowedOrigins = data.getString("allowedOrigins");
    r.allowedMethods = data.getString("allowedMethods");
    r.allowedHeaders = data.getString("allowedHeaders");
    r.exposedHeaders = data.getString("exposedHeaders");
    r.maxAgeSeconds = data.getInteger("maxAgeSeconds");

    auto result = usecase.createRule(r);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("CORS rule created successfully", 201, Json.emptyObject.set("id", result
        .id));
  }

  protected Json listByBucket(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto bucketId = Bucketid(extractBucketIdFromCorsPath(req.requestURI));
    if (bucketId.isEmpty)
      return errorResponse("Invalid bucket ID in path");

    auto rules = usecase.listRules(tenantId, bucketId);
    auto arr = rules.map!(r => r.toJson).array.toJson;

    return successResponse(
      "CORS rules retrieved successfully", 200, Json.emptyObject
        .set("items", arr)
        .set("totalCount", rules.length));
  }

  protected void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listByBucket(req);
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
    auto id = CorsRuleId(precheck.getString("id"));
    if (id.isEmpty)
      return errorResponse("Invalid CORS rule ID");

    auto rule = usecase.getRule(tenantId, id);
    if (rule.isNull)
      return errorResponse("CORS rule not found");

    return successResponse("CORS rule retrieved successfully", 200, rule.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CorsRuleId(precheck.getString("id"));
    if (id.isEmpty)
      return errorResponse("Invalid CORS rule ID");

    auto data = precheck.data;

    auto r = UpdateCorsRuleRequest();
    r.tenantId = tenantId;
    r.corsRuleId = id;
    r.allowedOrigins = data.getString("allowedOrigins");
    r.allowedMethods = data.getString("allowedMethods");
    r.allowedHeaders = data.getString("allowedHeaders");
    r.exposedHeaders = data.getString("exposedHeaders");
    r.maxAgeSeconds = data.getInteger("maxAgeSeconds");

    auto result = usecase.updateRule(r);
    if (result.hasError)
      return errorResponse(result
          .message, result.message == "CORS rule not found" ? 404 : 400);

    return successResponse("CORS rule updated successfully", 200, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CorsRuleId(precheck.getString("id"));
    if (id.isEmpty)
      return errorResponse("Invalid CORS rule ID");

    auto result = usecase.deleteRule(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message == "CORS rule not found" ? 404 : 400, result
          .message);

    return successResponse("CORS rule deleted successfully", 200);
  }

  private static string extractBucketIdFromCorsPath(string uri) {
    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;
    auto bucketsPos = path.indexOf("buckets/");
    if (bucketsPos < 0)
      return "";

    auto start = bucketsPos + 8;
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    
    return slashPos >= 0 ? rest[0 .. slashPos] : rest;
  }
}
