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
class BucketController : PlatformController {
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

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateBucketRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.region = j.getString("region");
      r.storageClass = j.getString("storageClass");
      r.versioningEnabled = j.getBoolean("versioningEnabled");
      r.encryptionType = j.getString("encryptionType");
      r.encryptionKeyId = j.getString("encryptionKeyId");
      r.quotaBytes = jsonLong(j, "quotaBytes");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createBucket(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto buckets = usecase.listBuckets(tenantId);
      auto arr = buckets.map!(b => b.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", buckets.length)
        .set("message", "Buckets retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      if (!existsBucket(id)) {
        writeError(res, 404, "Bucket not found");
        return;
      }

      auto bucket = usecase.getBucket(id);
      if (bucket.isNull) {
        writeError(res, 404, "Bucket not valid");
        return;
      }

      res.writeJsonBody(bucket.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateBucketRequest();
      r.storageClass = j.getString("storageClass");
      r.versioningEnabled = j.getBoolean("versioningEnabled");
      r.encryptionType = j.getString("encryptionType");
      r.encryptionKeyId = j.getString("encryptionKeyId");
      r.quotaBytes = jsonLong(j, "quotaBytes");

      auto result = usecase.updateBucket(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Bucket updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Bucket not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteBucket(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("id", result.id)
          .set("message", "Bucket deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto code = result.error == "Bucket not found" ? 404 : 409;
        writeError(res, code, result.error);
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
