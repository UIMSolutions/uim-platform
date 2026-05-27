/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.access_policy;

// 
// 
// import uim.platform.object_store.application.usecases.manage.access_policies;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.access_policy;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class AccessPolicyController : ManageController {
  private ManageAccessPoliciesUseCase usecase;

  this(ManageAccessPoliciesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/access-policies", &handleCreate);
    router.get("/api/v1/buckets/*/access-policies", &handleListByBucket);
    router.get("/api/v1/access-policies/*", &handleGet);
    router.put("/api/v1/access-policies/*", &handleUpdate);
    router.delete_("/api/v1/access-policies/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto r = CreateAccessPolicyRequest();
    r.tenantId = tenantId;
    r.bucketId = data.getString("bucketId");
    r.name = data.getString("name");
    r.effect = data.getString("effect");
    r.principal = data.getString("principal");
    r.actions = data.getString("actions");
    r.resources = data.getString("resources");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createPolicy(r);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Access policy created successfully", "Created", 201, Json.emptyObject.set("id", result
        .id));
  }

  protected Json listByBucketHandler(HTTPServerRequest req) {
    auto precheck = super.precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto bucketId = BucketId(extractBucketIdFromPoliciesPath(req.requestURI));
    if (bucketId.isNull)
      return errorResponse("Invalid bucket ID", 400);

    auto policies = usecase.listPolicies(tenantId, bucketId);
    auto arr = policies.map!(p => p.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", policies.length);

    return successResponse("Access policies retrieved successfully", "Retrieved", 200, responseData);
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

    auto tenantId = precheck.tenantId;
    auto id = AccessPolicyId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid access policy ID", 400);

    auto policy = usecase.getPolicy(tenantId, id);
    if (policy.isNull)
      return errorResponse("Policy not found", 404);

    return successResponse("Access policy retrieved successfully", "Retrieved", 200, policy.toJson);
  }

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AccessPolicyId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid access policy ID", 400);

    auto data = precheck.data;

    auto r = UpdateAccessPolicyRequest();
    r.tenantId = tenantId;
    r.accessPolicyId = id;
    r.name = data.getString("name");
    r.effect = data.getString("effect");
    r.principal = data.getString("principal");
    r.actions = data.getString("actions");
    r.resources = data.getString("resources");

    auto result = usecase.updatePolicy(r);
    if (result.hasError)
      return errorResponse(result.message, result.message == "Policy not found" ? 404 : 400);

    return successResponse("Access policy updated successfully", "Updated", 200, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AccessPolicyId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid access policy ID", 400);

    auto result = usecase.deletePolicy(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, result.message == "Policy not found" ? 404 : 400);

    return successResponse("Access policy deleted successfully", "Deleted", 200, Json.emptyObject.set("id", id));
  }

  /// Extract bucket ID from /api/v1/buckets/{id}/access-policies
  private static string extractBucketIdFromPoliciesPath(string uri) {
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
