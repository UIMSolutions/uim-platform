/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.version_;


// 
// 
// import uim.platform.dms.application.application.usecases.manage.versions;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

// mixin(ShowModule!());
@safe:

class VersionController : ManageHttpController {
  private ManageVersionsUseCase usecase;

  this(ManageVersionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/versions/checkout/*", &handleCheckOut);
    router.post("/api/v1/versions/checkin", &handleCheckIn);
    router.post("/api/v1/versions/cancel-checkout/*", &handleCancelCheckOut);
    router.get("/api/v1/versions/document/*", &handleGetAllVersions);
    router.get("/api/v1/versions/current/*", &handleGetCurrentVersion);
  }

  protected Json checkOutHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto docId = DocumentId(precheck.id);
    auto tenantId = precheck.tenantId;
    auto userId = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.checkOut(tenantId, docId, userId);
    if (result.isSuccess) {
      auto resp = Json.emptyObject
        .set("documentId", docId.value)
        .set("status", Json("locked"))
        .set("message", "Document checked out successfully");

      return successResponse("Document checked out successfully", "CheckedOut", 200, resp);
    }
    else
      return errorResponse(result.message, 400);
  }

  protected void handleCheckOut(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = DocumentId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto userId = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.checkOut(tenantId, docId, userId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("documentId", docId.value)
          .set("status", Json("locked"))
          .set("message", "Document checked out successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleckIn(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CheckInRequest();
      r.documentId = DocumentId(data.getString("documentId"));
      r.tenantId = tenantId;
      r.userId = UserId(req.headers.get("X-User-Id", "system"));
      r.isMajor = data.getBoolean("isMajor", true);
      r.comment = data.getString("comment");
      r.fileName = data.getString("fileName");
      r.mimeType = data.getString("mimeType");
      r.fileSize = data.getLong("fileSize");
      r.checksum = data.getString("checksum");

      auto result = usecase.checkIn(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("versionId", result.id)
          .set("documentId", r.documentId.value)
          .set("status", Json("active"))
          .set("message", "Document checked in successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleCancelCheckOut(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = DocumentId(precheck.id);
      auto tenantId = precheck.tenantId;

      auto result = usecase.cancelCheckOut(tenantId, docId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("documentId", docId.value)
          .set("status", Json("active"))
          .set("message", "Document checkout cancelled successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAllVersions(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = DocumentId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto versions = usecase.getAllVersions(tenantId, docId);
      auto arr = versions.map!(v => v.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(versions.length))
        .set("message", "Document versions retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGetCurrentVersion(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto docId = DocumentId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto ver = usecase.getCurrentVersion(tenantId, docId);
      if (ver.isNull)
      return errorResponse("Document not found", 404);
      
      res.writeJsonBody(ver.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
