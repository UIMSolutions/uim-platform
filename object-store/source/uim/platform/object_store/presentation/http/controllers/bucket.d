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

    auto tenantId = precheck.getTenantId;
    auto data = precheck["data"];

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
      return errorResponse(result.errorMessage);

    return successResponse("Bucket created successfully", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (!precheck.isNull)
      return precheck;
      
    auto tenantId = precheck.getTenantId;
    auto id = BucketId(precheck.getString("id"));
     if (id.isNull)
      return errorResponse("Invalid bucket ID", 400);

    auto data = precheck["data"];

    auto r = UpdateBucketRequest();
    r.tenantId = tenantId;
    r.bucketId = id;
    r.storageClass = data.getString("storageClass").to!StorageClass;
    r.versioningEnabled = data.getBoolean("versioningEnabled");
    r.encryptionType = data.getString("encryptionType").to!EncryptionType;
    r.encryptionKeyId = data.getString("encryptionKeyId");
    r.quotaBytes = jsonLong(data, "quotaBytes");

    auto result = usecase.updateBucket(r);
    if (result.hasError)
      return errorResponse(result.errorMessage, result.errorMessage == "Bucket not found" ? 404 : 400);

    return successResponse("Bucket updated successfully", 200, Json.emptyObject.set("id", result.id));
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BucketId(extractIdFromPath(req.requestURI));
      if (id.isNull) {
        writeError(res, 400, "Invalid bucket ID");
        return;
      }

      auto bucket = usecase.getBucket(tenantId, id);
      if (bucket.isNull) {
        writeError(res, 404, "Bucket not found");
        return;
      }

      res.writeJsonBody(bucket.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateBucketRequest();
      r.tenantId = tenantId;
      r.bucketId = id;
      r.storageClass = j.getString("storageClass").to!StorageClass;
      r.versioningEnabled = j.getBoolean("versioningEnabled");
      r.encryptionType = j.getString("encryptionType").to!EncryptionType;
      r.encryptionKeyId = j.getString("encryptionKeyId");
      r.quotaBytes = jsonLong(j, "quotaBytes");

      auto result = usecase.updateBucket(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Bucket updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.errorMessage == "Bucket not found" ? 404 : 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteBucket(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("id", result.id)
          .set("message", "Bucket deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto code = result.errorMessage == "Bucket not found" ? 404 : 409;
        writeError(res, code, result.errorMessage);
      }
    } catch (Exception e) { 
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeBucket(Bucket b) {
    return Json.emptyObject
      .set("id", b.id)
      .set("tenantId", b.tenantId)
      .set("name", b.name)
      .set("region", b.region)
      .set("storageClass", b.storageClass.to!string)
      .set("versioningEnabled", b.versioningEnabled)
      .set("encryptionType", b.encryptionType.to!string)
      .set("encryptionKeyId", b.encryptionKeyId)
      .set("status", b.status.to!string)
      .set("quotaBytes", b.quotaBytes)
      .set("usedBytes", b.usedBytes)
      .set("objectCount", b.objectCount)
      .set("createdBy", b.createdBy)
      .set("createdAt", b.createdAt)
      .set("updatedAt", b.updatedAt);
  }
}
