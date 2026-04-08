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
// import uim.platform.dms.application.presentation.http.json_utils;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class VersionController : SAPController {
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

      auto result = uc.checkOut(docId, tenantId, userId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["documentId"] = Json(docId);
        resp["status"] = Json("locked");
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
        auto resp = Json.emptyObject;
        resp["versionId"] = Json(result.id);
        resp["documentId"] = Json(r.documentId);
        resp["status"] = Json("active");
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

      auto result = uc.cancelCheckOut(docId, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["documentId"] = Json(docId);
        resp["status"] = Json("active");
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
      auto versions = uc.getAllVersions(docId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref v; versions)
        arr ~= serializeVersion(v);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) versions.length);
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
      auto ver = uc.getCurrentVersion(docId, tenantId);
      if (ver is null) {
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
    auto j = Json.emptyObject;
    j["id"] = Json(v.id);
    j["tenantId"] = Json(v.tenantId);
    j["documentId"] = Json(v.documentId);
    j["versionNumber"] = Json(v.versionNumber);
    j["isMajor"] = v.isMajor ? Json(true) : Json(false);
    j["fileName"] = Json(v.fileName);
    j["mimeType"] = Json(v.mimeType);
    j["fileSize"] = Json(v.fileSize);
    j["status"] = Json(v.status.to!string);
    j["comment"] = Json(v.comment);
    j["checksum"] = Json(v.checksum);
    j["createdBy"] = Json(v.createdBy);
    j["createdAt"] = Json(v.createdAt);
    return j;
  }
}
