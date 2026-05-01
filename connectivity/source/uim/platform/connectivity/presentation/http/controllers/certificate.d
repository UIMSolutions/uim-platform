/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.certificate;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;

// import uim.platform.connectivity.application.usecases.manage.certificates;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.certificate;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class CertificateController : PlatformController {
  private ManageCertificatesUseCase uc;

  this(ManageCertificatesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/certificates", &handleCreate);
    router.get("/api/v1/certificates", &handleList);
    router.get("/api/v1/certificates/*", &handleGetById);
    router.put("/api/v1/certificates/*", &handleUpdate);
    router.delete_("/api/v1/certificates/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateCertificateRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.certType = j.getString("type");
      r.usage = j.getString("usage");
      r.subjectDN = j.getString("subjectDN");
      r.issuerDN = j.getString("issuerDN");
      r.serialNumber = j.getString("serialNumber");
      r.fingerprint = j.getString("fingerprint");
      r.validFrom = jsonLong(j, "validFrom");
      r.validTo = jsonLong(j, "validTo");

      auto result = uc.createCertificate(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Certificate created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto certs = uc.listCertificates(tenantId);

      auto arr = Json.emptyArray;
      foreach (c; certs)
        arr ~= serializeCert(c);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(certs.length));

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto cert = uc.getCertificate(id);
      if (cert.id.isEmpty) {
        writeError(res, 404, "Certificate not found");
        return;
      }
      res.writeJsonBody(serializeCert(cert), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateCertificateRequest();
      r.description = j.getString("description");
      r.active = j.getBoolean("active", true);

      auto result = uc.updateCertificate(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Certificate updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Certificate not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteCertificate(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", Json(true))
          .set("message", "Certificate deleted successfully");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeCert(const Certificate c) {
    return Json.emptyObject
      .set("id", Json(c.id))
      .set("tenantId", Json(c.tenantId))
      .set("name", Json(c.name))
      .set("description", Json(c.description))
      .set("type", Json(c.certType.to!string))
      .set("usage", Json(c.usage.to!string))
      .set("subjectDN", Json(c.subjectDN))
      .set("issuerDN", Json(c.issuerDN))
      .set("serialNumber", Json(c.serialNumber))
      .set("fingerprint", Json(c.fingerprint))
      .set("validFrom", Json(c.validFrom))
      .set("validTo", Json(c.validTo))
      .set("active", Json(c.active))
      .set("createdAt", Json(c.createdAt))
      .set("updatedAt", Json(c.updatedAt));
  }
}
