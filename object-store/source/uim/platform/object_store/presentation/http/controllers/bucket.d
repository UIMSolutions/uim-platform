module uim.platform.object_store.presentation.http.controllers.bucket;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;
// 
// import uim.platform.object_store.application.use_cases.manage_buckets;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.bucket;
// import uim.platform.object_store.presentation.http.json_utils;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class BucketController : SAPController {
  private ManageBucketsUseCase uc;

  this(ManageBucketsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/buckets", &handleCreate);
    router.get("/api/v1/buckets", &handleList);
    router.get("/api/v1/buckets/*", &handleGetById);
    router.put("/api/v1/buckets/*", &handleUpdate);
    router.delete_("/api/v1/buckets/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateBucketRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.region = j.getString("region");
      r.storageClass = j.getString("storageClass");
      r.versioningEnabled = j.getBoolean("versioningEnabled");
      r.encryptionType = j.getString("encryptionType");
      r.encryptionKeyId = j.getString("encryptionKeyId");
      r.quotaBytes = jsonLong(j, "quotaBytes");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createBucket(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto buckets = uc.listBuckets(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref b; buckets)
        arr ~= serializeBucket(b);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)buckets.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      if (!existsBucket(id)) {
        writeError(res, 404, "Bucket not found");
        return;
      }

      auto bucket = uc.getBucket(id);
      if (bucket.id.length == 0) {
        writeError(res, 404, "Bucket not valid");
        return;
      }

      res.writeJsonBody(serializeBucket(bucket), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateBucketRequest();
      r.storageClass = j.getString("storageClass");
      r.versioningEnabled = j.getBoolean("versioningEnabled");
      r.encryptionType = j.getString("encryptionType");
      r.encryptionKeyId = j.getString("encryptionKeyId");
      r.quotaBytes = jsonLong(j, "quotaBytes");

      auto result = uc.updateBucket(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Bucket not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteBucket(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
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
    auto j = Json.emptyObject;
    j["id"] = Json(b.id);
    j["tenantId"] = Json(b.tenantId);
    j["name"] = Json(b.name);
    j["region"] = Json(b.region);
    j["storageClass"] = Json(b.storageClass.to!string);
    j["versioningEnabled"] = Json(b.versioningEnabled);
    j["encryptionType"] = Json(b.encryptionType.to!string);
    j["encryptionKeyId"] = Json(b.encryptionKeyId);
    j["status"] = Json(b.status.to!string);
    j["quotaBytes"] = Json(b.quotaBytes);
    j["usedBytes"] = Json(b.usedBytes);
    j["objectCount"] = Json(b.objectCount);
    j["createdBy"] = Json(b.createdBy);
    j["createdAt"] = Json(b.createdAt);
    j["updatedAt"] = Json(b.updatedAt);
    return j;
  }
}
