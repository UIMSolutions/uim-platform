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
class ObjectController : ManageHttpController {
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

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CreateObjectRequest();

    r.tenantId = tenantId;
    r.bucketId = data.getString("bucketId");
    r.key = data.getString("key");
    r.contentType = data.getString("contentType");
    r.size = data.getLong("size");
    r.metadata = data.getString("metadata");
    r.storageClass = data.getString("storageClass");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createObject(r);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Object created successfully", "Created", 201, responseData);
  }

  protected Json listByBucketHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto bucketId = BucketId(extractBucketIdFromPath(req.requestURI));
    auto prefix = queryParam(req, "prefix");

    StorageObject[] objects = prefix.length > 0
      ? usecase.listObjects(tenantId, bucketId, prefix) : usecase.listObjects(tenantId, bucketId);

    auto arr = objects.map!(o => o.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", objects.length);

    return successResponse("Objects retrieved successfully", "OK", 200, resp);
  }

  mixin(HandleTemplate!("handleListByBucket", "listByBucketHandler"));

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = StorageObjectId(precheck.id);

    // Check if this is a versions request
    if (id.value == "versions" || id.value == "copy")
      return errorResponse("Invalid object ID", 400);

    auto obj = usecase.getObject(tenantId, id);
    if (obj.isNull)
      return errorResponse("Object not found", 404);

    return successResponse("Object retrieved successfully", "Retrieved", 200, obj.toJson);
  }

  protected Json updateMetadataHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BucketId(extractIdFromPath(precheck.path));
    auto data = precheck.data;

    auto r = UpdateObjectMetadataRequest();
    r.tenantId = tenantId;
    r.bucketId = id;
    r.contentType = data.getString("contentType");
    r.metadata = data.getString("metadata");
    r.storageClass = data.getString("storageClass");

    auto result = usecase.updateObjectMetadata(r);
    if (result.hasError)
      return errorResponse(result.errorMessage == "Object not found" ? "Not Found" : "Bad Request", result
          .errorMessage == "Object not found" ? 404 : 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Object metadata updated successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleUpdateMetadata", "updateMetadataHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = StorageObjectId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid object ID", 400);

    auto result = usecase.deleteObject(tenantId, id);
    if (result.hasError)
      return errorResponse(result.errorMessage == "Object not found" ? "Not Found" : "Bad Request", result
          .errorMessage == "Object not found" ? 404 : 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Object deleted successfully", "Deleted", 200, resp);
  }

  protected Json copyHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CopyObjectRequest();
    r.tenantId = tenantId;
    r.sourceBucketId = data.getString("sourceBucketId");
    r.sourceKey = data.getString("sourceKey");
    r.destBucketId = data.getString("destBucketId");
    r.destKey = data.getString("destKey");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.copyObject(r);
    if (result.hasError)
      return errorResponse(result.errorMessage, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Object copied successfully", "Created", 201, resp);
  }

  mixin(HandleTemplate!("handleCopy", "copyHandler"));

  protected Json listVersionsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = StorageObjectId(extractObjectIdFromVersionsPath(req.requestURI));
    if (id.isNull)
      return errorResponse("Invalid object ID", 400);

    auto versions = usecase.listVersions(tenantId, id);
      auto arr = versions.map!(v => v.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", versions.length);

    return successResponse("Object versions retrieved successfully", "OK", 200, resp);
  }

  mixin(HandleTemplate!("handleListVersions", "listVersionsHandler"));

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
