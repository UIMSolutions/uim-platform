/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.object;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.object_store.application.usecases.manage.objects;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.storage_object;
// import uim.platform.object_store.domain.entities.object_version;
// import uim.platform.object_store.presentation.http.json_utils;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class ObjectController : PlatformController {
  private ManageObjectsUseCase uc;

  this(ManageObjectsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/objects", &handleCreate);
    router.get("/api/v1/buckets/*/objects", &handleListByBucket);
    router.get("/api/v1/objects/*", &handleGetById);
    router.put("/api/v1/objects/*", &handleUpdateMetadata);
    router.delete_("/api/v1/objects/*", &handleDelete);
    router.post("/api/v1/objects/copy", &handleCopy);
    router.get("/api/v1/objects/*/versions", &handleListVersions);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateObjectRequest();
      r.tenantId = req.getTenantId;
      r.bucketId = j.getString("bucketId");
      r.key = j.getString("key");
      r.contentType = j.getString("contentType");
      r.size = jsonLong(j, "size");
      r.metadata = j.getString("metadata");
      r.storageClass = j.getString("storageClass");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createObject(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // Extract bucket ID from: /api/v1/buckets/{bucketId}/objects
      auto path = req.requestURI;
      auto bucketId = extractBucketIdFromPath(path);
      auto prefix = queryParam(req, "prefix");

      StorageObject[] objects;
      if (prefix.length > 0)
        objects = uc.listObjectsByPrefix(bucketId, prefix);
      else
        objects = uc.listObjects(bucketId);

      auto arr = Json.emptyArray;
      foreach (o; objects)
        arr ~= serializeObject(o);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(objects.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      // Check if this is a versions request
      if (id == "versions" || id == "copy")
        return;

      auto obj = uc.getObject(id);
      if (obj.isNull || obj.id.isEmpty) {
        writeError(res, 404, "Object not found");
        return;
      }
      res.writeJsonBody(serializeObject(obj), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdateMetadata(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateObjectMetadataRequest();
      r.contentType = j.getString("contentType");
      r.metadata = j.getString("metadata");
      r.storageClass = j.getString("storageClass");

      auto result = uc.updateObjectMetadata(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Object not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteObject(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCopy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CopyObjectRequest();
      r.tenantId = req.getTenantId;
      r.sourceBucketId = j.getString("sourceBucketId");
      r.sourceKey = j.getString("sourceKey");
      r.destBucketId = j.getString("destBucketId");
      r.destKey = j.getString("destKey");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.copyObject(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListVersions(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // /api/v1/objects/{objectId}/versions
      auto path = req.requestURI;
      auto objectId = extractObjectIdFromVersionsPath(path);

      auto versions = uc.listVersions(objectId);

      auto arr = Json.emptyArray;
      foreach (v; versions)
        arr ~= serializeVersion(v);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(versions.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeObject(StorageObject o) {
    return Json.emptyObject
    .set("id", o.id)
    .set("tenantId", o.tenantId)
    .set("bucketId", o.bucketId)
    .set("key", o.key)
    .set("contentType", o.contentType)
    .set("size", o.size)
    .set("etag", o.etag)
    .set("metadata", o.metadata)
    .set("storageClass", o.storageClass.to!string)
    .set("status", o.status.to!string)
    .set("currentVersionId", o.currentVersionId)
    .set("createdBy", o.createdBy)
    .set("createdAt", o.createdAt)
    .set("updatedAt", o.updatedAt);
  }

  private static Json serializeVersion(ObjectVersion v) {
    return Json.emptyObject
    .set("id", v.id)
    .set("objectId", v.objectId)
    .set("versionTag", v.versionTag)
    .set("size", v.size)
    .set("etag", v.etag)
    .set("contentType", v.contentType)
    .set("isLatest", v.isLatest)
    .set("isDeleteMarker", v.isDeleteMarker)
    .set("createdBy", v.createdBy)
    .set("createdAt", v.createdAt);
  }

  /// Extract bucket ID from /api/v1/buckets/{id}/objects
  private static string extractBucketIdFromPath(string uri) {
    // import std.string : indexOf;

    // Remove query string
    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    // Find "buckets/" and extract next segment
    auto bucketsPos = path.indexOf("buckets/");
    if (bucketsPos < 0)
      return "";
    auto start = bucketsPos + 8; // length of "buckets/"
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    if (slashPos > 0)
      return rest[0 .. slashPos];
    return rest;
  }

  /// Extract object ID from /api/v1/objects/{id}/versions
  private static string extractObjectIdFromVersionsPath(string uri) {
    // import std.string : indexOf;

    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    auto objectsPos = path.indexOf("objects/");
    if (objectsPos < 0)
      return "";
    auto start = objectsPos + 8;
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    if (slashPos > 0)
      return rest[0 .. slashPos];
    return rest;
  }
}
