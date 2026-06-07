/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.identity_provider;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class IdentityProviderController : ManageHttpController {
  private ManageIdentityProvidersUseCase usecase;

  this(ManageIdentityProvidersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/identity-providers", &handleCreate);
    router.get("/api/v1/identity-providers", &handleList);
    router.get("/api/v1/identity-providers/*", &handleGet);
    router.put("/api/v1/identity-providers/*", &handleUpdate);
    router.delete_("/api/v1/identity-providers/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto idps = usecase.listProviders(tenantId);
    auto list = idps.map!(idp => idp.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", list)
      .set("totalCount", list.length);

    return successResponse("Identity provider list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateIdentityProviderRequest r;
    r.tenantId = tenantId;
    r.alias_ = data.getString("alias");
    r.displayName = data.getString("displayName");
    r.idpType = data.getString("idpType");
    r.metadataUrl = data.getString("metadataUrl");
    r.entityId = data.getString("entityId");
    r.ssoUrl = data.getString("ssoUrl");
    r.sloUrl = data.getString("sloUrl");
    r.signingCert = data.getString("signingCert");
    r.isActive = data.getBoolean("isActive");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.createProvider(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Identity provider created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = IdentityProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid identity provider ID", 400);

    auto idp = usecase.getProvider(tenantId, id);
    if (idp.isNull)
      return errorResponse("Identity provider not found", 404);

    auto responseData = idp.toJson();
    return successResponse("Identity provider retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto data = precheck.data;

    auto id = IdentityProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid identity provider ID", 400);

    UpdateIdentityProviderRequest r;
    r.tenantId = tenantId;
    r.providerId = id;
    r.displayName = data.getString("displayName");
    r.metadataUrl = data.getString("metadataUrl");
    r.ssoUrl = data.getString("ssoUrl");
    r.sloUrl = data.getString("sloUrl");
    r.signingCert = data.getString("signingCert");
    r.isActive = data.getBoolean("isActive");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.updateProvider(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Identity provider updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = IdentityProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid identity provider ID", 400);

    auto result = usecase.deleteProvider(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Identity provider deleted successfully", "Deleted", 200, responseData);
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class IdentityProviderControllerTest : ControllerTestBase {
    void runTests() {
      auto repo = new MemoryIdentityProviderRepository();
      auto usecase = new ManageIdentityProvidersUseCase(repo);
      auto controller = new IdentityProviderController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 1. Create
      Json createData = Json.emptyObject
        .set("alias", "sap-id-service")
        .set("displayName", "SAP ID Service")
        .set("idpType", "saml")
        .set("metadataUrl", "https://idp.example.com/metadata")
        .set("isActive", true)
        .set("isDefault", false);

      auto reqCreate = createMockRequest("POST", "/api/v1/identity-providers", tenantId, createData);
      auto resCreate = controller.createHandler(reqCreate);
      assert(resCreate.getString("status") == "success");
      string providerId = resCreate["data"]["id"].get!string;

      // 2. List
      auto reqList = createMockRequest("GET", "/api/v1/identity-providers", tenantId);
      auto resList = controller.listHandler(reqList);
      assert(resList.getString("status") == "success");
      assert(resList["data"]["totalCount"].get!int == 1);

      // 3. Get
      auto reqGet = createMockRequest("GET", "/api/v1/identity-providers/" ~ providerId, tenantId);
      reqGet.params["id"] = providerId;
      auto resGet = controller.getHandler(reqGet);
      assert(resGet.getString("status") == "success");
      assert(resGet["data"]["alias"].get!string == "sap-id-service");

      // 4. Update
      Json updateData = Json.emptyObject
        .set("displayName", "Updated IDP Name")
        .set("isActive", false);
      auto reqUpdate = createMockRequest("PUT", "/api/v1/identity-providers/" ~ providerId, tenantId, updateData);
      reqUpdate.params["id"] = providerId;
      auto resUpdate = controller.updateHandler(reqUpdate);
      assert(resUpdate.getString("status") == "success");
      
      auto updatedIdp = repo.findById(tenantId, IdentityProviderId(providerId));
      assert(updatedIdp.displayName == "Updated IDP Name");
      assert(updatedIdp.isActive == false);

      // 5. Delete
      auto reqDelete = createMockRequest("DELETE", "/api/v1/identity-providers/" ~ providerId, tenantId);
      reqDelete.params["id"] = providerId;
      auto resDelete = controller.deleteHandler(reqDelete);
      assert(resDelete.getString("status") == "success");
      assert(repo.countByTenant(tenantId) == 0);
    }
  }

  (new IdentityProviderControllerTest).runTests();
}
