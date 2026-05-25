/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.object;

// 
// 
// import uim.platform.object_store.application.usecases.manage.objects;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.storage_object;
// import uim.platform.object_store.domain.entities.object_version;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class ObjectController : ManageController {
  private ManageObjectsUseCase usecase;

  this(ManageObjectsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/objects", &handleCreate);
    router.get("/api/v1/buckets/*/objects", &handleListByBucket);
    router.get("/api/v1/objects/*", &handleGet);
    router.put("/api/v1/objects/*", &handleUpdateMetadata);
    router.delete_("/api/v1/objects/*", &handleDelete);
    router.post("/api/v1/objects/copy", &handleCopy);
    router.get("/api/v1/objects/*/versions", &handleListVersions);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto j = req.json;
    auto r = CreateObjectRequest();

    r.tenantId = tenantId;
    r.bucketId = j.getString("bucketId");
    r.key = j.getString("key");
    r.contentType = j.getString("contentType");
    r.size = jsonLong(j, "size");
    r.metadata = j.getString("metadata");
    r.storageClass = j.getString("storageClass");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createObject(r);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Object created successfully", "Created", 201, resp);
  }

  protected Json listByBucketHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto bucketId = BucketId(extractBucketIdFromPath(req.requestURI));
    auto prefix = queryParam(req, "prefix");

    StorageObject[] objects = prefix.length > 0
      ? usecase.listObjects(tenantId, bucketId, prefix) : usecase.listObjects(tenantId, bucketId);

    auto arr = objects.map!(o => o.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", objects.length)
      .set("message", "Objects retrieved successfully");

    return successResponse("Objects retrieved successfully", "OK", 200, resp);
  }

  protected void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listByBucketHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto id = StorageObjectId(extractIdFromPath(req.requestURI));
    // Check if this is a versions request
    if (id == "versions" || id == "copy")
      return errorResponse("Invalid object ID", 400);

    auto obj = usecase.getObject(tenantId, id);
    if (obj.isNull)
      return errorResponse("Object not found", 404);

    return successResponse("Object retrieved successfully", "Retrieved", 200, obj.toJson);
  }

  protected Json updateMetadataHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BucketId(extractIdFromPath(req.requestURI));
    auto j = req.json;
    auto r = UpdateObjectMetadataRequest();
    r.tenantId = tenantId;
    r.bucketId = id;
    r.contentType = j.getString("contentType");
    r.metadata = j.getString("metadata");
    r.storageClass = j.getString("storageClass");

    auto result = usecase.updateObjectMetadata(r);
    if (result.hasError)
      return errorResponse(result.errorMessage == "Object not found" ? "Not Found" : "Bad Request", result
          .errorMessage == "Object not found" ? 404 : 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Object metadata updated successfully", "Updated", 200, resp);
  }

  override protected void handleUpdateMetadata(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = updateMetadataHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto id = extractIdFromPath(req.requestURI);

    auto result = usecase.deleteObject(tenantId, id);
    if (result.hasError)
      return errorResponse(result.errorMessage == "Object not found" ? "Not Found" : "Bad Request", result
          .errorMessage == "Object not found" ? 404 : 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Object deleted successfully");

    return successResponse("Object deleted successfully", "Deleted", 200, resp);
  }

  protected Json copyHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId;
    auto j = req.json;
    auto r = CopyObjectRequest();
    r.tenantId = tenantId;
    r.sourceBucketId = j.getString("sourceBucketId");
    r.sourceKey = j.getString("sourceKey");
    r.destBucketId = j.getString("destBucketId");
    r.destKey = j.getString("destKey");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.copyObject(r);
    if (result.hasError)
      return errorResponse(result.errorMessage, "Bad Request", 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Object copied successfully");

    return successResponse("Object copied successfully", "Created", 201, resp);
  }

  protected void handleCopy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = copyHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json listVersionsHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto objectId = extractObjectIdFromVersionsPath(req.requestURI);

    auto versions = usecase.listVersions(tenantId, objectId);
    auto arr = versions.map!(v => v.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", versions.length);

    return successResponse("Object versions retrieved successfully", "OK", 200, resp);
  }

  protected void handleListVersions(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listVersionsHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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
