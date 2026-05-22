/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.lifecycle_rule;

// 

// import uim.platform.object_store.application.usecases.manage.lifecycle_rules;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.lifecycle_rule;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class LifecycleRuleController : ManageController {
  private ManageLifecycleRulesUseCase usecase;

  this(ManageLifecycleRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/lifecycle-rules", &handleCreate);
    router.get("/api/v1/buckets/*/lifecycle-rules", &handleListByBucket);
    router.get("/api/v1/lifecycle-rules/*", &handleGet);
    router.put("/api/v1/lifecycle-rules/*", &handleUpdate);
    router.delete_("/api/v1/lifecycle-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto data = precheck["data"];

    auto request = CreateLifecycleRuleRequest();
    request.tenantId = tenantId;
    request.bucketId = data.getString("bucketId");
    request.name = data.getString("name");
    request.prefix = data.getString("prefix");
    request.status = data.getString("status");
    request.expirationDays = data.getInteger("expirationDays");
    request.transitionDays = data.getInteger("transitionDays");
    request.transitionStorageClass = data.getString("transitionStorageClass");
    request.abortIncompleteUploadDays = data.getInteger("abortIncompleteUploadDays");
    request.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createRule(request);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Lifecycle rule created successfully", 201, Json.emptyObject.set("id", result
        .id));
  }

  protected Json listByBucketHandler(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.getTenantId;
    auto bucketId = BucketId(extractBucketIdFromRulesPath(req.requestURI));
    if (bucketId.isNull)
      return errorResponse("Invalid bucket ID");

    auto rules = usecase.listRules(tenantId, bucketId);
    auto arr = rules.map!(r => r.toJson).array.toJson;

    return successResponse("Lifecycle rules retrieved successfully", 200, Json.emptyObject
        .set("items", arr)
        .set("totalCount", rules.length));
  }

  protected void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listByBucketHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.getTenantId;
    auto id = LifecycleRuleId(precheck.getString("id"));
    if (id.isNull)
      return errorResponse("Invalid lifecycle rule ID");

    auto rule = usecase.getRule(tenantId, id);
    if (rule.isNull)
      return errorResponse("Lifecycle rule not found");

    return successResponse("Lifecycle rule retrieved successfully", 200, rule.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.getTenantId;
    auto id = LifecycleRuleId(precheck.getString("id"));
    auto data = precheck["data"];

    UpdateLifecycleRuleRequest request;
    request.tenantId = tenantId;
    request.lifecycleRuleId = id;
    request.name = data.getString("name");
    request.prefix = data.getString("prefix");
    request.status = data.getString("status");
    request.expirationDays = data.getInteger("expirationDays");
    request.transitionDays = data.getInteger("transitionDays");
    request.transitionStorageClass = data.getString("transitionStorageClass");
    request.abortIncompleteUploadDays = data.getInteger("abortIncompleteUploadDays");

    auto result = usecase.updateRule(id, request);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Lifecycle rule updated successfully", 200, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.getTenantId;
    auto id = LifecycleRuleId(precheck.getString("id"));

    auto result = usecase.deleteRule(tenantId, id);
    if (!result.success)
      return errorResponse(result.message);

    return successResponse("Lifecycle rule deleted successfully", 200, Json.emptyObject.set("id", id));
  }

  private static string extractBucketIdFromRulesPath(string uri) {
    // import std.string : indexOf;

    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    auto bucketsPos = path.indexOf("buckets/");
    if (bucketsPos < 0)
      return "";
    auto start = bucketsPos + 8;
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    if (slashPos > 0)
      return rest[0 .. slashPos];
    return rest;
  }
}
