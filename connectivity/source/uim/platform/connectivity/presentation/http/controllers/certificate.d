/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.certificate;

// 
// import uim.platform.connectivity.application.usecases.manage.certificates;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.certificate;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class CertificateController : ManageController {
  private ManageCertificatesUseCase usecase;

  this(ManageCertificatesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/certificates", &handleCreate);
    router.get("/api/v1/certificates", &handleList);
    router.get("/api/v1/certificates/*", &handleGet);
    router.put("/api/v1/certificates/*", &handleUpdate);
    router.delete_("/api/v1/certificates/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateCertificateRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.certType = data.getString("type");
    r.usage = data.getString("usage");
    r.subjectDN = data.getString("subjectDN");
    r.issuerDN = data.getString("issuerDN");
    r.serialNumber = data.getString("serialNumber");
    r.fingerprint = data.getString("fingerprint");
    r.validFrom = jsonLong(j, "validFrom");
    r.validTo = jsonLong(j, "validTo");

    auto result = usecase.createCertificate(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Certificate created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto certs = usecase.listCertificates(tenantId);
    auto arr = certs.map!(c => c.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(certs.length))
      .set("message", "Certificates retrieved successfully");

    res.writeJsonBody(resp, 200);
  }
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);

    auto cert = usecase.getCertificate(tenantId, id);
    if (cert.isNull) {
      writeError(res, 404, "Certificate not found");
      return;
    }
    res.writeJsonBody(cert.toJson, 200);
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = UpdateCertificateRequest();
    r.certificateId = CertificateId(precheck.id);
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.active = data.getBoolean("active", true);

    auto result = usecase.updateCertificate(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Certificate updated successfully");

    res.writeJsonBody(resp, 200);
  } else {
    writeError(res, result.message == "Certificate not found" ? 404 : 400, result.message);
  }
} catch (Exception e) {
  writeError(res, 500, "Internal server error");
}
}

override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    auto result = usecase.deleteCertificate(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("deleted", true)
      .set("message", "Certificate deleted successfully");

    res.writeJsonBody(resp, 200);
  } else {
    writeError(res, 404, result.message);
  }
} catch (Exception e) {
  writeError(res, 500, "Internal server error");
}
}
}
