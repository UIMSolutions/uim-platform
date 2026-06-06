/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.certificates;

import uim.platform.destination;

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

    UploadCertificateRequest r;
    r.tenantId = tenantId;
    r.subaccountId = SubaccountId(data.getString("subaccountId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.certificateType = data.getString("certificateType");
    r.format_ = data.getString("format");
    r.content = data.getString("content");
    r.password = data.getString("password");
    r.uploadedBy = data.getString("uploadedBy");

    auto result = usecase.upload(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Certificate uploaded successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto subaccountId = SubaccountId(req.params.get("subaccountId", ""));
    auto certificateType = req.params.get("certificateType", "");

    if (certificateType.length > 0 && !usecase.supportsCertificateType(certificateType))
      return errorResponse("Invalid certificate type: " ~ certificateType, 400);

    auto certificates = certificateType.length > 0
      ? usecase.listByType(tenantId, subaccountId, certificateType)
      : usecase.listBySubaccount(tenantId, subaccountId);

    auto items = Json.emptyArray;
    foreach (c; certificates) {
      items ~= Json.emptyObject
        .set("id", c.id)
        .set("name", c.name)
        .set("subaccountId", c.subaccountId)
        .set("status", c.status.to!string);
    }

    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", certificates.length);

    return successResponse("Certificates retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    auto cert = usecase.getCertificate(tenantId, id);
    if (cert.isNull)
      return errorResponse("Certificate not found", 404);

    auto response = Json.emptyObject
      .set("id", cert.id)
      .set("name", cert.name)
      .set("description", cert.description)
      .set("certificateType", cert.certificateType.to!string)
      .set("format", cert.format_.to!string)
      .set("status", cert.status.to!string);

    return successResponse("Certificate retrieved successfully", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CertificateId(precheck.id);
    auto data = precheck.data;

    UpdateCertificateRequest r;
    r.tenantId = tenantId;
    r.certificateId = id;
    r.description = data.getString("description");
    r.content = data.getString("content");

    auto result = usecase.updateCertificate(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Certificate updated successfully", 200, resp);
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

    auto resp = Json.emptyObject.set("id", id);
    return successResponse("Certificate deleted successfully", 200, resp);
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class CertificateControllerTest : ControllerTestBase {
    void runTests() {
      auto repo = new MemoryCertificateRepository();
      auto usecase = new ManageCertificatesUseCase(repo);
      auto controller = new CertificateController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 1. Create (Upload)
      Json uploadData = Json.emptyObject
        .set("subaccountId", "sub-1")
        .set("name", "test-cert")
        .set("certificateType", "keystore")
        .set("format", "pem")
        .set("content", "---BEGIN CERTIFICATE---")
        .set("uploadedBy", "user-1");

      auto reqCreate = createMockRequest("POST", "/api/v1/certificates", tenantId, uploadData);
      auto resCreate = controller.createHandler(reqCreate);
      assert(resCreate.getString("status") == "success");
      string certId = resCreate["data"]["id"].get!string;

      // 2. List
      auto reqList = createMockRequest("GET", "/api/v1/certificates", tenantId);
      reqList.params["subaccountId"] = "sub-1";
      auto resList = controller.listHandler(reqList);
      assert(resList.getString("status") == "success");
      assert(resList["data"]["totalCount"].get!int == 1);

      auto reqTypedList = createMockRequest("GET", "/api/v1/certificates", tenantId);
      reqTypedList.params["subaccountId"] = "sub-1";
      reqTypedList.params["certificateType"] = "key-store";
      auto resTypedList = controller.listHandler(reqTypedList);
      assert(resTypedList.getString("status") == "success");
      assert(resTypedList["data"]["totalCount"].get!int == 1);

      auto reqInvalidTypedList = createMockRequest("GET", "/api/v1/certificates", tenantId);
      reqInvalidTypedList.params["subaccountId"] = "sub-1";
      reqInvalidTypedList.params["certificateType"] = "pem";
      auto resInvalidTypedList = controller.listHandler(reqInvalidTypedList);
      assert(resInvalidTypedList.getString("status") == "error");
      assert(resInvalidTypedList.getInteger("code") == 400);

      // 3. Get
      auto reqGet = createMockRequest("GET", "/api/v1/certificates/" ~ certId, tenantId);
      reqGet.params["id"] = certId;
      auto resGet = controller.getHandler(reqGet);
      assert(resGet.getString("status") == "success");
      assert(resGet["data"]["name"].get!string == "test-cert");

      // 4. Update
      Json updateData = Json.emptyObject
        .set("description", "Updated description");
      auto reqUpdate = createMockRequest("PUT", "/api/v1/certificates/" ~ certId, tenantId, updateData);
      reqUpdate.params["id"] = certId;
      auto resUpdate = controller.updateHandler(reqUpdate);
      assert(resUpdate.getString("status") == "success");

      // 5. Delete
      auto reqDelete = createMockRequest("DELETE", "/api/v1/certificates/" ~ certId, tenantId);
      reqDelete.params["id"] = certId;
      auto resDelete = controller.deleteHandler(reqDelete);
      assert(resDelete.getString("status") == "success");
    }
  }

  (new CertificateControllerTest).runTests();
}