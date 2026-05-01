/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.version_;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.dms.application.application.usecases.manage.versions;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class VersionController : PlatformController {
  private ManageVersionsUseCase uc;

  this(ManageVersionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/versions/checkout/*", &handleCheckOut);
    router.post("/api/v1/versions/checkin", &handleCheckIn);
    router.post("/api/v1/versions/cancel-checkout/*", &handleCancelCheckOut);
    router.get("/api/v1/versions/document/*", &handleGetAllVersions);
    router.get("/api/v1/versions/current/*", &handleGetCurrentVersion);
  }

  private void handleCheckOut(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto userId = req.headers.get("X-User-Id", "system");

      auto result = uc.checkOut(doctenantId, id, userId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("documentId", Json(docId))
          .set("status", Json("locked"))
          .set("message", Json("Document checked out successfully"));

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCheckIn(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CheckInRequest();
      r.documentId = j.getString("documentId");
      r.tenantId = req.getTenantId;
      r.userId = req.headers.get("X-User-Id", "system");
      r.isMajor = j.getBoolean("isMajor", true);
      r.comment = j.getString("comment");
      r.fileName = j.getString("fileName");
      r.mimeType = j.getString("mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.checksum = j.getString("checksum");

      auto result = uc.checkIn(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("versionId", Json(result.id))
          .set("documentId", Json(r.documentId))
          .set("status", Json("active"))
          .set("message", Json("Document checked in successfully"));

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCancelCheckOut(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;

      auto result = uc.cancelCheckOut(doctenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("documentId", Json(docId))
          .set("status", Json("active"))
          .set("message", Json("Document checkout cancelled successfully"));

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetAllVersions(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto versions = uc.getAllVersions(doctenantId, id);
      auto arr = versions.map!(v => serializeVersion(v)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(versions.length));
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetCurrentVersion(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto ver = uc.getCurrentVersion(doctenantId, id);
      if (ver.isNull) {
        writeError(res, 404, "No current version found");
        return;
      }
      res.writeJsonBody(serializeVersion(ver), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeVersion(const DocumentVersion v) {
    return Json.emptyObject
      .set("id", Json(v.id))
      .set("tenantId", Json(v.tenantId))
      .set("documentId", Json(v.documentId))
      .set("versionNumber", Json(v.versionNumber))
      .set("isMajor", v.isMajor ? Json(true) : Json(false))
      .set("fileName", Json(v.fileName))
      .set("mimeType", Json(v.mimeType))
      .set("fileSize", Json(v.fileSize))
      .set("status", Json(v.status.to!string))
      .set("comment", Json(v.comment))
      .set("checksum", Json(v.checksum))
      .set("createdBy", Json(v.createdBy))
      .set("createdAt", Json(v.createdAt));
  }
}
