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
    router.get("/api/v1/versions/document/*", &handleAllVersions);
    router.get("/api/v1/versions/current/*", &handleCurrentVersion);
  }

  protected Json checkOutHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto docId = DocumentId(precheck.id);
    auto tenantId = precheck.tenantId;
    auto userId = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.checkOut(tenantId, docId, userId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("documentId", docId.value)
      .set("status", Json("locked"));

    return successResponse("Document checked out successfully", "CheckedOut", 200, resp);
  }

  mixin(HandleTemplate!("handleCheckOut", "checkOutHandler"));

  protected Json checkInHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

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
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("versionId", result.id)
      .set("documentId", r.documentId.value)
      .set("status", Json("active"));

    return successResponse("Document checked in successfully", "CheckedIn", 201, resp);
  }

  mixin(HandleTemplate!("handleCheckIn", "checkInHandler"));

  protected Json cancelCheckOutHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto docId = DocumentId(precheck.id);
    auto tenantId = precheck.tenantId;

    auto result = usecase.cancelCheckOut(tenantId, docId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("documentId", docId.value)
      .set("status", Json("active"));

    return successResponse("Document checkout cancelled successfully", "Cancelled", 200, resp);
  }

  mixin(HandleTemplate!("handleCancelCheckOut", "cancelCheckOutHandler"));

  protected Json allVersionsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto versions = usecase.getAllVersions(tenantId, id).map!(v => v.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", versions)
      .set("totalCount", versions.length);

    return successResponse("Document versions retrieved successfully", "Retrieved", 200, resp);
  }

  mixin(HandleTemplate!("handleAllVersions", "allVersionsHandler"));

  protected Json getCurrentVersionHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto ver = usecase.getCurrentVersion(tenantId, id);
    if (ver.isNull)
      return errorResponse("Document not found", 404);

    return successResponse("Current document version retrieved successfully", "Retrieved", 200, ver
        .toJson);
  }

  mixin(HandleTemplate!("handleCurrentVersion", "getCurrentVersionHandler"));

}
