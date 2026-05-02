/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.share;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.dms.application.application.usecases.manage.shares;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.share;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class ShareController : PlatformController {
  private ManageSharesUseCase uc;

  this(ManageSharesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/shares", &handleCreate);
    router.get("/api/v1/shares", &handleList);
    router.get("/api/v1/shares/*", &handleGetById);
    router.post("/api/v1/shares/revoke/*", &handleRevoke);
    router.delete_("/api/v1/shares/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateShareRequest();
      r.tenantId = req.getTenantId;
      r.documentId = j.getString("documentId");
      r.shareType = parseShareType(j.getString("shareType"));
      r.sharedWith = j.getString("sharedWith");
      r.permissionLevel = parsePermissionLevel(j.getString("permissionLevel"));
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createShare(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Share created successfully"));

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto shares = uc.listShares(tenantId);

      auto arr = shares.map!(share => share.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", shares.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto share = uc.getShare(tenantId, id);
      if (share.isNull) {
        writeError(res, 404, "Share not found");
        return;
      }
      res.writeJsonBody(share.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.revokeShare(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("status", Json("revoked"))
          .set("message", Json("Share revoked"));

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.deleteShare(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeShare(const Share s) {
    return Json.emptyObject
      .set("id", s.id)
      .set("tenantId", s.tenantId)
      .set("documentId", s.documentId)
      .set("shareType", s.shareType.to!string)
      .set("sharedWith", s.sharedWith)
      .set("permissionLevel", s.permissionLevel.to!string)
      .set("status", s.status.to!string)
      .set("expiresAt", s.expiresAt)
      .set("createdBy", s.createdBy)
      .set("createdAt", s.createdAt);
  }
}
