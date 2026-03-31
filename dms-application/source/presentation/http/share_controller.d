module presentation.http.share_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_shares;
import application.dto;
import domain.entities.share;
import domain.types;
import presentation.http.json_utils;

class ShareController
{
  private ManageSharesUseCase uc;

  this(ManageSharesUseCase uc)
  {
    this.uc = uc;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/shares", &handleCreate);
    router.get("/api/v1/shares", &handleList);
    router.get("/api/v1/shares/*", &handleGetById);
    router.post("/api/v1/shares/revoke/*", &handleRevoke);
    router.delete_("/api/v1/shares/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateShareRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.documentId = jsonStr(j, "documentId");
      r.shareType = parseShareType(jsonStr(j, "shareType"));
      r.sharedWith = jsonStr(j, "sharedWith");
      r.permissionLevel = parsePermissionLevel(jsonStr(j, "permissionLevel"));
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createShare(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listShares(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; items)
        arr ~= serializeShare(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto share = uc.getShare(id, tenantId);
      if (share is null)
      {
        writeError(res, 404, "Share not found");
        return;
      }
      res.writeJsonBody(serializeShare(share), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.revokeShare(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("revoked");
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteShare(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeShare(const Share s)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["tenantId"] = Json(s.tenantId);
    j["documentId"] = Json(s.documentId);
    j["shareType"] = Json(s.shareType.to!string);
    j["sharedWith"] = Json(s.sharedWith);
    j["permissionLevel"] = Json(s.permissionLevel.to!string);
    j["status"] = Json(s.status.to!string);
    j["expiresAt"] = Json(s.expiresAt);
    j["createdBy"] = Json(s.createdBy);
    j["createdAt"] = Json(s.createdAt);
    return j;
  }
}
