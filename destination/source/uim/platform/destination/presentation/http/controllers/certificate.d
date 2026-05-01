/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.certificate;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.destination.application.usecases.manage.certificates;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.types;
// import uim.platform.destination.presentation.http.json_utils;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class CertificateController : PlatformController {
  private ManageCertificatesUseCase uc;

  this(ManageCertificatesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/certificates", &handleUpload);
    router.get("/api/v1/certificates", &handleList);
    router.get("/api/v1/certificates/expiring", &handleListExpiring);
    router.get("/api/v1/certificates/*", &handleGetById);
    router.put("/api/v1/certificates/*", &handleUpdate);
    router.delete_("/api/v1/certificates/*", &handleDelete);
    router.post("/api/v1/certificates/validate/*", &handleValidate);
  }

  private void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UploadCertificateRequest r;
      r.tenantId = req.getTenantId;
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
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
      r.uploadedBy = req.headers.get("X-User-Id", "");

      auto result = uc.upload(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", Json("Certificate uploaded"));

        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      auto typeFilter = req.params.get("type");

      Certificate[] certs;
      if (typeFilter.length > 0)
        certs = uc.listByType(tenantId, subaccountId, typeFilter);
      else
        certs = uc.listBySubaccount(tenantId, subaccountId);

      auto arr = Json.emptyArray;
      foreach (c; certs)
        arr ~= serializeCertificate(c);

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(certs.length));

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListExpiring(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      // import std.datetime.systime : Clock;

      auto now = Clock.currTime().toUnixTime();
      auto thirtyDays = now + 30 * 86_400;

      auto certs = uc.listExpiring(tenantId, thirtyDays);

      auto arr = Json.emptyArray;
      foreach (c; certs)
        arr ~= serializeCertificate(c);

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(certs.length));

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = CertificateId(extractIdFromPath(req.requestURI));
      auto c = uc.getCertificate(id);
      if (c.isNull) {
        writeError(res, 404, "Certificate not found");
        return;
      }
      res.writeJsonBody(serializeCertificate(c), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = CertificateId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateCertificateRequest r;
      r.description = j.getString("description");
      r.content = j.getString("content");
      r.password = j.getString("password");
      r.validFrom = jsonLong(j, "validFrom");
      r.validTo = jsonLong(j, "validTo");

      auto result = uc.updateCertificate(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", Json("Certificate updated"));

        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Certificate not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = CertificateId(extractIdFromPath(req.requestURI));
      auto result = uc.removeCertificate(id);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("deleted", Json(true));

        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = CertificateId(extractIdFromPath(req.requestURI));
      auto result = uc.validateCertificate(id);

      auto resp = Json.emptyObject
        .set("isValid", Json(result.isValid))
        .set("status", Json(result.status.to!string))
        .set("message", Json(result.message))
        .set("daysUntilExpiry", Json(result.daysUntilExpiry));
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeCertificate(const ref Certificate c) {
    return Json.emptyObject
    .set("id", c.id.toJson())
    .set("tenantId", c.tenantId.toJson())
    .set("subaccountId", c.subaccountId.toJson())
    .set("name", c.name)
    .set("description", c.description)
    .set("type", c.certificateType.to!string)
    .set("format", c.format_.to!string)
    .set("status", c.status.to!string)
    .set("subject", c.subject)
    .set("issuer", c.issuer)
    .set("serialNumber", c.serialNumber)
    .set("validFrom", c.validFrom)
    .set("validTo", c.validTo)
    .set("uploadedBy", c.uploadedBy)
    .set("uploadedAt", c.uploadedAt)
    .set("updatedAt", c.updatedAt);
  }
}
