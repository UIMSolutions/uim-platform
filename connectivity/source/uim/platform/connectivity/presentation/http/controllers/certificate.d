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
class CertificateController : ManageHttpController {
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
    r.validFrom = jsonLong(data, "validFrom");
    r.validTo = jsonLong(data, "validTo");

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
    auto list = certs.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Certificate list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto item = usecase.getCertificate(tenantId, id);
    if (item.isNull)
      return errorResponse("Certificate not found", 404);

    auto responseData = item.toJson();
    return successResponse("Certificate retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

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

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Certificate updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid certificate ID", 400);

    auto result = usecase.deleteCertificate(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Certificate deleted successfully", "Deleted", 200, responseData);
  }
}
