/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.directory;

// 
// import uim.platform.management.application.usecases.manage.directories;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
class DirectoryController : ManageHttpController {
  private ManageDirectoriesUseCase usecase;

  this(ManageDirectoriesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/directories", &handleCreate);
    router.get("/api/v1/directories", &handleList);
    router.get("/api/v1/directories/*", &handleGet);
    router.put("/api/v1/directories/*", &handleUpdate);
    router.delete_("/api/v1/directories/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto gaId = GlobalAccountId(req.params.get("globalAccountId"));
    auto parentId = DirectoryId(req.params.get("parentDirectoryId"));

    Directory[] items;
    if (!parentId.isEmpty)
      items = usecase.listDirectories(tenantId, parentId);
    else if (!gaId.isEmpty)
      items = usecase.listDirectories(tenantId, gaId);

    auto arr = items.map!(d => d.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Directory list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateDirectoryRequest r;
    r.tenantId = tenantId;
    r.accountId = data.getString("globalAccountId");
    r.parentDirectoryId = data.getString("parentDirectoryId");
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.features = getStrings(data, "features");
    r.manageEntitlements = data.getBoolean("manageEntitlements");
    r.manageAuthorizations = data.getBoolean("manageAuthorizations");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.labels = jsonStrMap(data, "labels");
    r.customProperties = jsonStrMap(data, "customProperties");

    auto result = usecase.createDirectory(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Directory created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = DirectoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid directory ID", 400);

    auto d = usecase.getDirectory(tenantId, id);
    if (d.isNull)
      return errorResponse("Directory not found", 404);

    auto responseData = d.toJson();
    return successResponse("Directory retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto data = precheck.data;

    auto id = DirectoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid directory ID", 400);

    UpdateDirectoryRequest request;
    request.tenantId = tenantId;
    request.directoryId = id;
    request.displayName = data.getString("displayName");
    request.description = data.getString("description");
    request.labels = jsonStrMap(data, "labels");
    request.customProperties = jsonStrMap(data, "customProperties");

    auto result = usecase.updateDirectory(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Directory updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DirectoryId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid directory ID", 400);

    auto result = usecase.deleteDirectory(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Directory deleted successfully", "Deleted", 200, responseData);
  }
}
///
unittest {
  import uim.platform.service.tests;

  @safe class DirectoryControllerTest : ControllerTestBase {
    void runTests() {
      // 1. Setup
      auto repo = new MemoryDirectoryRepository();
      auto usecase = new ManageDirectoriesUseCase(repo);
      auto controller = new DirectoryController(usecase);

      // 2. Test List Handler (Initially empty)
      auto tenantId = TenantId("test-tenant");
      auto reqList = createMockRequest("GET", "/api/v1/directories", tenantId);
      reqList.params["globalAccountId"] = "test-account";
      auto resList = controller.listHandler(reqList);
      writeln("List Response: ", resList);
      // assertSuccess(resList, 200);
      // assert(resList["data"]["totalCount"].get!int == 0);

      // 3. Test Create Handler
      Json createData = Json.emptyObject
        .set("globalAccountId", "test-account")
        .set("displayName", "Test Directory")
        .set("description", "A test directory")
        .set("features", ["ENTITLEMENTS", "AUTHORIZATIONS"].toJson)
        .set("manageEntitlements", true)
        .set("labels", Json.emptyObject.set("env", "test"));

    //   auto reqCreate = createMockRequest("POST", "/api/v1/directories", "test-tenant", createData);
    //   auto resCreate = controller.createHandler(reqCreate);
    //   writeln("Create Response: ", resCreate);
    //   string createdId = resCreate["data"]["id"].get!string;
    //   // assertSuccess(resCreate, 201);

    //   // 4. Test Get Handler
    //   auto reqGet = createMockRequest("GET", "/api/v1/directories/" ~ createdId);
    //   // Simulating the precheck logic usually handled by the base class
    //   // reqGet.params["id"] = createdId; 
    //   auto resGet = controller.getHandler(reqGet);
    //   writeln("Get Response: ", resGet);
    //   // assertSuccess(resGet, 200);
    //   // assert(resGet["data"]["displayName"].get!string == "Test Directory");

    //   // 5. Test Update Handler
    //   Json updateData = Json.emptyObject
    //     .set("displayName", "Updated Name")
    //     .set("description", "Updated description");
    //   auto reqUpdate = createMockRequest("PUT", "/api/v1/directories/" ~ createdId, "test-tenant", updateData);
    //   auto resUpdate = controller.updateHandler(reqUpdate);
    //   writeln("Update Response: ", resUpdate);
    //   // assertSuccess(resUpdate, 200);

    //   // 6. Test List Handler (Again, should have 1 item)
    //   auto resList2 = controller.listHandler(reqList);
    //   writeln("List Response (Post-Create): ", resList2);
    //   // assert(resList2["data"]["totalCount"].get!int == 1);

    //   // 7. Test Delete Handler
    //   auto reqDelete = createMockRequest("DELETE", "/api/v1/directories/" ~ createdId);
    //   auto resDelete = controller.deleteHandler(reqDelete);
    //   writeln("Delete Response: ", resDelete);
    //   // assertSuccess(resDelete, 200);

    //   // 8. Test Get Handler (Should be 404)
    //   auto resGet404 = controller.getHandler(reqGet);
    //   writeln("Get 404 Response: ", resGet404);
    //   // assert(resGet404["code"].get!int == 404);
    }
  }

  auto runner = new DirectoryControllerTest();
  runner.runTests();
}
