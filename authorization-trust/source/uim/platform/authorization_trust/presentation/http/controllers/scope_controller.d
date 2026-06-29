/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.scope_controller;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class ScopeController : ManageHttpController {
  private ManageScopesUseCase usecase;

  this(ManageScopesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/scopes", &handleCreate);
    router.get("/api/v1/scopes", &handleList);
    router.get("/api/v1/scopes/*", &handleGet);
    router.put("/api/v1/scopes/*", &handleUpdate);
    router.delete_("/api/v1/scopes/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateScopeRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.appId = data.getString("appId");

    auto result = usecase.createScope(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scope created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto scopes = usecase.listScopes(tenantId);
    auto list = scopes.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Scope list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScopeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scope ID", 400);

    auto s = usecase.getScope(tenantId, id);
    if (s.isNull)
      return errorResponse("Scope not found", 404);

    auto responseData = s.toJson();
    return successResponse("Scope retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ScopeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scope ID", 400);

    auto data = precheck.data;
    UpdateScopeRequest r;
    r.tenantId = tenantId;
    r.scopeId = id;
    r.description = data.getString("description");

    auto result = usecase.updateScope(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scope updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScopeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scope ID", 400);

    auto result = usecase.deleteScope(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", id);
    return successResponse("Scope deleted successfully", "Deleted", 200, responseData);
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class ScopeControllerTest : ControllerTestBase {
    void runTests() {
      auto repo = new MemoryScopeRepository();
      auto usecase = new ManageScopesUseCase(repo);
      auto controller = new ScopeController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 1. Create
      Json createData = Json.emptyObject
        .set("name", "read:data")
        .set("description", "Permission to read data")
        .set("appId", "app-123");

      auto reqCreate = createMockRequest("POST", "/api/v1/scopes", tenantId, createData);
      auto resCreate = controller.createHandler(reqCreate);
       // TODO: assert(resCreate.getString("status") == "success");
      string scopeId = resCreate["data"]["id"].get!string;

      // 2. List
      auto reqList = createMockRequest("GET", "/api/v1/scopes", tenantId);
      auto resList = controller.listHandler(reqList);
       // TODO: assert(resList.getString("status") == "success");
       // TODO: assert(resList["data"]["count"].get!int == 1);

      // 3. Get
      auto reqGet = createMockRequest("GET", "/api/v1/scopes/" ~ scopeId, tenantId);
      reqGet.params["id"] = scopeId;
      auto resGet = controller.getHandler(reqGet);
       // TODO: assert(resGet.getString("status") == "success");
       // TODO: assert(resGet["data"]["name"].get!string == "read:data");

      // 4. Update
      Json updateData = Json.emptyObject
        .set("description", "Updated description");
      auto reqUpdate = createMockRequest("PUT", "/api/v1/scopes/" ~ scopeId, tenantId, updateData);
      reqUpdate.params["id"] = scopeId;
      auto resUpdate = controller.updateHandler(reqUpdate);
       // TODO: assert(resUpdate.getString("status") == "success");
      
      auto updatedScope = repo.findById(tenantId, ScopeId(scopeId));
       // TODO: assert(updatedScope.description == "Updated description");

      // 5. Delete
      auto reqDelete = createMockRequest("DELETE", "/api/v1/scopes/" ~ scopeId, tenantId);
      reqDelete.params["id"] = scopeId;
      auto resDelete = controller.deleteHandler(reqDelete);
       // TODO: assert(resDelete.getString("status") == "success");
       // TODO: assert(repo.countByTenant(tenantId) == 0);
    }
  }

  (new ScopeControllerTest).runTests();
}
