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

  protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UploadCertificateRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.certificateType = j.getString("type");
      r.format_ = j.getString("format");
      r.content = j.getString("content");
      r.password = j.getString("password");
      r.subject = j.getString("subject");
      r.issuer = j.getString("issuer");
      r.serialNumber = j.getString("serialNumber");
      r.validFrom = jsonLong(j, "validFrom");
      r.validTo = jsonLong(j, "validTo");
      r.uploadedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.upload(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Certificate uploaded");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
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

  protected void handleListExpiring(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto now = Clock.currTime().toUnixTime();
      auto thirtyDays = now + 30 * 86_400;

      auto certs = usecase.listExpiring(tenantId, thirtyDays);

      auto arr = certs.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(certs.length))
        .set("message", "Expiring certificates retrieved successfully");

      res.writeJsonBody(resp, 200);
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
    auto id = CertificateId(extractIdFromPath(req.requestURI));
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto data = precheck.data;

    UpdateCertificateRequest r;
    r.tenantId = tenantId;
    r.certificateId = id;
    r.description = data.getString("description");
    r.content = data.getString("content");
    r.password = data.getString("password");
    r.validFrom = jsonLong(data, "validFrom");
    r.validTo = jsonLong(data, "validTo");

    auto result = usecase.updateCertificate(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Certificate updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = CertificateId(extractIdFromPath(path));
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto result = usecase.deleteCertificate(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("id", id);

    return successResponse("Certificate deleted successfully", 200, resp);
  }

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = CertificateId(extractIdFromPath(req.requestURI));
      auto result = usecase.validateCertificate(tenantId, id);

      auto resp = Json.emptyObject
        .set("isValid", result.isValid)
        .set("status", result.status.to!string)
        .set("message", (result.message))
        .set("daysUntilExpiry", Json(result.daysUntilExpiry))
        .set("message", "Certificate validation completed");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
