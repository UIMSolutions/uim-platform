/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.share;

// 
// 
// import uim.platform.dms.application.application.usecases.manage.shares;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.share;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class ShareController : ManageHttpController {
  private ManageSharesUseCase usecase;

  this(ManageSharesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/shares", &handleCreate);
    router.get("/api/v1/shares", &handleList);
    router.get("/api/v1/shares/*", &handleGet);
    router.post("/api/v1/shares/revoke/*", &handleRevoke);
    router.delete_("/api/v1/shares/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateShareRequest();
    r.tenantId = tenantId;
    r.documentId = DocumentId(data.getString("documentId"));
    r.shareType = data.getString("shareType").to!ShareType;
    r.sharedWith = data.getString("sharedWith");
    r.permissionLevel = data.getString("permissionLevel").to!PermissionLevel;
    r.expiresAt = data.getLong("expiresAt");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createShare(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("", 0, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto shares = usecase.listShares(tenantId);

    auto arr = shares.map!(share => share.toJson).array.toJson;

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ShareId(precheck.id);

    auto item = usecase.getShare(tenantId, id);
    if (item.isNull)
      return errorResponse("Share not found", 404);

    auto responseData = item.toJson();
    return successResponse("Share retrieved successfully", "Retrieved", 200, responseData);
  }

  protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ShareId(precheck.id);

      auto result = usecase.revokeShare(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", Json("revoked"))
          .set("message", "Share revoked");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ShareId(precheck.id);

    auto result = usecase.deleteShare(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Share deleted successfully", 200, responseData);
  }
}
