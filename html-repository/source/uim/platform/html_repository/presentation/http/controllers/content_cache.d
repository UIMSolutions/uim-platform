/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.content_cache;
// import uim.platform.html_repository.application.usecases.manage.content_cache;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class ContentCacheController : ManageHttpController {
  protected ManageContentCacheUseCase usecase;

  this(ManageContentCacheUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cache", &handleCreate);
    router.get("/api/v1/cache", &handleList);
    router.get("/api/v1/cache/*", &handleGet);
    router.delete_("/api/v1/cache/*", &handleDelete);
    router.post("/api/v1/cache/purge", &handlePurge);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CacheContentRequest r;
    r.tenantId = tenantId;
    r.fileId = AppFileId(data.getString("fileId"));
    r.filePath = data.getString("filePath");
    r.contentType = data.getString("contentType");
    r.content = data.getString("content");
    // TODO: r.etag = data.getString("etag");
    r.ttlSeconds = data.getLong("ttlSeconds");

    auto result = usecase.cacheContent(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Cache entry created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listContent(tenantId);

    auto arr = Json.emptyArray;
    foreach (e; items) {
      arr ~= Json.emptyObject
        .set("id", e.id)
        .set("fileId", e.fileId)
        .set("filePath", e.filePath)
        .set("status", e.status.toString())
        .set("hitCount", e.hitCount);
    }

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);
    return successResponse("Cache entries retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ContentCacheId(precheck.id);
    if (id.isNull)
      return errorResponse("Cache entry not found", 404);

    auto entry = usecase.getContent(tenantId, id);
    if (entry.isNull)
      return errorResponse("Cache entry not found", 404);

    auto response = Json.emptyObject
      .set("id", entry.id)
      .set("fileId", entry.fileId)
      .set("filePath", entry.filePath)
      .set("contentType", entry.contentType) // TODO: .set("data", entry.data)
      .set("etag", entry.etag)
      .set("ttlSeconds", entry.ttlSeconds)
      .set("status", entry.status.toString())
      .set("hitCount", entry.hitCount)
      .set("createdAt", entry.createdAt)
      .set("expiresAt", entry.expiresAt);

    return successResponse("Cache entry retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ContentCacheId(precheck.id);
    if (id.isNull)
      return errorResponse("Cache entry not found", 404);

    auto result = usecase.invalidateContent(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Cache entry invalidated successfully", "Invalidated", 200, Json.emptyObject);
  }

  protected Json purgeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = usecase.purgeExpiredContent(tenantId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("status", "purged");

    return successResponse("Expired cache entries purged successfully", "Purged", 200, resp);
  }

  mixin(HandleTemplate!("handlePurge", "purgeHandler"));

}
