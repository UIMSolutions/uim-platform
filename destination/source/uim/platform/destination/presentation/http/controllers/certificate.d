/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.certificate;
// import uim.platform.destination.application.usecases.manage.certificates;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class CertificateController : ManageController {
  private ManageCertificatesUseCase usecase;

  this(ManageCertificatesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/certificates", &handleUpload);
    router.get("/api/v1/certificates", &handleList);
    router.get("/api/v1/certificates/expiring", &handleListExpiring);
    router.get("/api/v1/certificates/*", &handleGet);
    router.put("/api/v1/certificates/*", &handleUpdate);
    router.delete_("/api/v1/certificates/*", &handleDelete);
    router.post("/api/v1/certificates/validate/*", &handleValidate);
  }

  protected Json uploadHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

      auto tenantId = precheck.tenantId;

      auto data = precheck.data;
      UploadCertificateRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.certificateType = data.getString("type");
      r.format_ = data.getString("format");
      r.content = data.getString("content");
      r.password = data.getString("password");
      r.subject = data.getString("subject");
      r.issuer = data.getString("issuer");
      r.serialNumber = data.getString("serialNumber");
      r.validFrom = data.getLong("validFrom");
      r.validTo = data.getLong("validTo");
      r.uploadedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.upload(r);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto responseData = Json.emptyObject.set("id", result.id);
      return successResponse("Certificate uploaded successfully", 201, responseData);
  }

  protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = uploadHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
    auto typeFilter = req.params.get("type");

    Certificate[] certs = typeFilter.length > 0
      ? usecase.listByType(tenantId, subaccountId, typeFilter) : usecase.listBySubaccount(tenantId, subaccountId);

    auto arr = certs.map!(c => c.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", certs.length);

    return successResponse("Certificates retrieved successfully", 200, resp);
  }

  protected Json listExpiringHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto now = Clock.currTime().toUnixTime();
    auto thirtyDays = now + 30 * 86_400;

    auto certs = usecase.listExpiring(tenantId, thirtyDays);
    auto arr = certs.map!(c => c.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", certs.length);

    return successResponse("Expiring certificates retrieved successfully", 200, resp);
  }
  protected void handleListExpiring(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listExpiringHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto c = usecase.getCertificate(tenantId, id);
    if (c.isNull)
      return errorResponse("Certificate not found", 404);

    return successResponse("Certificate retrieved successfully", 200, c.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto data = precheck.data;

    UpdateCertificateRequest r;
    r.tenantId = tenantId;
    r.certificateId = id;
    r.description = data.getString("description");
    r.content = data.getString("content");
    r.password = data.getString("password");
    r.validFrom = data.getLong("validFrom");
    r.validTo = data.getLong("validTo");

    auto result = usecase.updateCertificate(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Certificate updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = CertificateId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto result = usecase.deleteCertificate(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto responseData = Json.emptyObject.set("id", id);
    return successResponse("Certificate deleted successfully", 200, responseData);
  }

  protected Json validateHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

      auto tenantId = precheck.tenantId;
      auto id = CertificateId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid certificate ID", 400);

      auto result = usecase.validateCertificate(tenantId, id);
      if (result.hasError)
        return errorResponse("Certificate validation failed", 400);

      auto resp = Json.emptyObject
        .set("isValid", result.isValid)
        .set("status", result.status.to!string)
        .set("message", (result.message))
        .set("daysUntilExpiry", Json(result.daysUntilExpiry));

      return successResponse("Certificate validation completed", 200, resp);
  }

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = validateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
