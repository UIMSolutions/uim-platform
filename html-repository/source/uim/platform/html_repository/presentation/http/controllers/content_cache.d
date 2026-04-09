/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.content_cache;

import uim.platform.html_repository.application.usecases.manage.content_cache;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.htmls;

import std.conv : to;

class ContentCacheController : PlatformController {
  private ManageContentCacheUseCase uc;

  this(ManageContentCacheUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/cache", &handleCreate);
    router.get("/api/v1/cache", &handleList);
    router.get("/api/v1/cache/*", &handleGet);
    router.delete_("/api/v1/cache/*", &handleDelete);
    router.post("/api/v1/cache/purge", &handlePurge);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateContentCacheRequest r;
      r.tenantId = req.getTenantId;
      r.fileId = j.getString("fileId");
      r.filePath = j.getString("filePath");
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.etag = j.getString("etag");
      r.ttlSeconds = jsonLong(j, "ttlSeconds");

      auto result = uc.create(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(e.id);
        obj["fileId"] = Json(e.fileId);
        obj["filePath"] = Json(e.filePath);
        obj["status"] = Json(e.status);
        obj["hitCount"] = Json(cast(long) e.hitCount);
        arr ~= obj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Cache entry not found");
        return;
      }
      auto entry = uc.get_(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Cache entry not found");
        return;
      }
      auto obj = Json.emptyObject;
      obj["id"] = Json(entry.id);
      obj["fileId"] = Json(entry.fileId);
      obj["filePath"] = Json(entry.filePath);
      obj["contentType"] = Json(entry.contentType);
      obj["data"] = Json(entry.data);
      obj["etag"] = Json(entry.etag);
      obj["ttlSeconds"] = Json(entry.ttlSeconds);
      obj["status"] = Json(entry.status);
      obj["hitCount"] = Json(cast(long) entry.hitCount);
      obj["createdAt"] = Json(entry.createdAt);
      obj["expiresAt"] = Json(entry.expiresAt);
      res.writeJsonBody(obj, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (id.isEmpty) {
        writeError(res, 404, "Cache entry not found");
        return;
      }
      auto result = uc.invalidate(id, tenantId);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handlePurge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto result = uc.purgeExpired(tenantId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("purged");
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
