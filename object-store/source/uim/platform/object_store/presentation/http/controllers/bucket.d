/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.bucket;

// 
// 
// import uim.platform.object_store.application.usecases.manage.buckets;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.bucket;
// import uim.platform.object_store.presentation.http

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class BucketController : ManageController {
  private ManageBucketsUseCase usecase;

  this(ManageBucketsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/buckets", &handleCreate);
    router.get("/api/v1/buckets", &handleList);
    router.get("/api/v1/buckets/*", &handleGet);
    router.put("/api/v1/buckets/*", &handleUpdate);
    router.delete_("/api/v1/buckets/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto r = CreateBucketRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.region = data.getString("region");
    r.storageClass = data.getString("storageClass");
    r.versioningEnabled = data.getBoolean("versioningEnabled");
    r.encryptionType = data.getString("encryptionType");
    r.encryptionKeyId = data.getString("encryptionKeyId");
    r.quotaBytes = jsonLong(data, "quotaBytes");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createBucket(r);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Bucket created successfully", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = req.getTenantId;
    auto id = BucketId(extractIdFromPath(req.requestURI));
    if (id.isNull)
      return errorResponse("Invalid bucket ID", 400);

    auto bucket = usecase.getBucket(tenantId, id);
    if (bucket.isNull)
      return errorResponse("Bucket not found", 404);

    return successResponse("Bucket retrieved successfully", 200, serializeBucket(bucket));
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BucketId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid bucket ID", 400);

    auto data = precheck.data;

    UpdateBucketRequest r;
    r.tenantId = tenantId;
    r.bucketId = id;
    r.storageClass = data.getString("storageClass");
    r.versioningEnabled = data.getBoolean("versioningEnabled");
    r.encryptionType = data.getString("encryptionType");
    r.encryptionKeyId = data.getString("encryptionKeyId");
    r.quotaBytes = jsonLong(data, "quotaBytes");

    auto result = usecase.updateBucket(r);
    if (result.hasError)
      return errorResponse(result.message, result.message == "Bucket not found" ? 404 : 400);

    return successResponse("Bucket updated successfully", 200, Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = req.getTenantId;
    auto id = BucketId(extractIdFromPath(req.requestURI));
    if (id.isNull)
      return errorResponse("Invalid bucket ID", 400);

    auto result = usecase.deleteBucket(tenantId, id);
    if (result.hasError) {
      auto code = result.message == "Bucket not found" ? 404 : 409;
      return errorResponse(result.message, code);
    }

    auto resp = Json.emptyObject
      .set("deleted", true);

    return successResponse("Bucket deleted successfully", "Deleted", 200, resp);
  }
}
