/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.broker_service;

import std.uuid : randomUUID;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class BrokerServiceController : ManageHttpController {
  private ManageBrokerServicesUseCase usecase;

  this(ManageBrokerServicesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/event-mesh/broker-services", &handleList);
    router.get("/api/v1/event-mesh/broker-services/*", &handleGet);
    router.post("/api/v1/event-mesh/broker-services", &handleCreate);
    router.put("/api/v1/event-mesh/broker-services/*", &handleUpdate);
    router.delete_("/api/v1/event-mesh/broker-services/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listServices(tenantId);
    auto list = items.map!(e => e.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);

    return successResponse("Broker service list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = BrokerServiceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid broker service ID", "BadRequest", 400);

    auto service = usecase.getService(tenantId, id);
    if (service.isNull)
      return errorResponse("Broker service not found", "Not Found", 404);

    auto resp = Json.emptyObject
      .set("message", "Broker service retrieved successfully")
      .set("resource", service.toJson);

    return successResponse("Broker service retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto createId = precheck.id;
    if (createId.isEmpty) {
      try {
        createId = req.params["id"];
      } catch (Exception) {
      }
    }
    if (createId.isEmpty)
      createId = randomUUID().toString();

    BrokerServiceDTO dto;
    dto.serviceId = BrokerServiceId(createId);
    dto.tenantId = precheck.tenantId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.region = data.getString("region");
    dto.datacenter = data.getString("datacenter");
    dto.version_ = data.getString("version");
    dto.maxConnections = data.getString("maxConnections");
    dto.maxQueueDepth = data.getString("maxQueueDepth");
    dto.maxMessageSize = data.getString("maxMessageSize");
    dto.msgVpnName = data.getString("msgVpnName");
    dto.createdBy = UserId(data.getString("createdBy"));

    auto service = usecase.createService(dto);
    if (service.hasError)
      return errorResponse("Failed to create broker service", "Bad Request", 400);

    auto resp = Json.emptyObject
      .set("id", service.id);

    return successResponse("Broker service created successfully", "Created", 201, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BrokerServiceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid broker service ID", "Bad Request", 400);

    auto data = precheck.data;

    BrokerServiceDTO dto;
    dto.tenantId = precheck.tenantId;
    dto.serviceId = id;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.region = data.getString("region");
    dto.maxConnections = data.getString("maxConnections");
    dto.maxQueueDepth = data.getString("maxQueueDepth");
    dto.maxMessageSize = data.getString("maxMessageSize");
    dto.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.updateService(dto);
    if (result.hasError)
      return errorResponse(result.message, "Bad Request", 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Broker service updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BrokerServiceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid broker service ID", "Bad Request", 400);

    auto result = usecase.deleteService(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, "Bad Request", 400);

    auto resp = Json.emptyObject
      .set("message", "Broker service deleted");

    return successResponse("Broker service deleted successfully", "Deleted", 200, resp);
  }
}
///
unittest {
  import uim.platform.service.tests;

  @safe class BrokerServiceControllerTest : ControllerTestBase {
    void runTests() {
      // 1. Setup
      auto repo = new FileBrokerServiceRepository();
      auto usecase = new ManageBrokerServicesUseCase(repo);
      auto controller = new BrokerServiceController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 2. Test List Handler
      auto reqList = createMockRequest("GET", "/api/v1/event-mesh/broker-services", tenantId);
      auto resList = controller.listHandler(reqList);
      assert(resList.getString("status") != "error");
      assert(resList["data"]["count"].get!int == 0);

      // 3. Test Create Handler
      Json createData = Json.emptyObject
        .set("name", "Test Broker")
        .set("description", "A test broker service")
        .set("region", "eu-central-1")
        .set("createdBy", "user-1");

      auto reqCreate = createMockRequest("POST", "/api/v1/event-mesh/broker-services", tenantId, createData);
      reqCreate.params["id"] = "broker-1";
      auto resCreate = controller.createHandler(reqCreate);
      assert(resCreate.getString("status") != "error");
      auto createdId = resCreate["data"]["id"].get!string;
      assert(createdId.length > 0);

      // 4. Test Get Handler
      auto reqGet = createMockRequest("GET", "/api/v1/event-mesh/broker-services/" ~ createdId, tenantId);
      reqGet.params["id"] = createdId;
      auto resGet = controller.getHandler(reqGet);
      assert(resGet.getString("status") != "error");
      assert(resGet["data"]["resource"]["name"].get!string == "Test Broker");

      // 5. Test Update Handler
      Json updateData = Json.emptyObject
        .set("name", "Updated Broker")
        .set("updatedBy", "user-2");
      auto reqUpdate = createMockRequest(
        "PUT",
        "/api/v1/event-mesh/broker-services/" ~ createdId,
        tenantId,
        updateData);
      reqUpdate.params["id"] = createdId;
      auto resUpdate = controller.updateHandler(reqUpdate);
      assert(resUpdate.getString("status") != "error");

      // Verify update
      auto resGet2 = controller.getHandler(reqGet);
      assert(resGet2["data"]["resource"]["name"].get!string == "Updated Broker");

      // 6. Test Delete Handler
      auto reqDelete = createMockRequest("DELETE", "/api/v1/event-mesh/broker-services/" ~ createdId, tenantId);
      reqDelete.params["id"] = createdId;
      auto resDelete = controller.deleteHandler(reqDelete);
      assert(resDelete.getString("status") != "error");

      // Verify deletion
      auto resGet3 = controller.getHandler(reqGet);
      assert(resGet3.getString("status") == "error"); // Expect 404
    }
  }

  auto runner = new BrokerServiceControllerTest();
  runner.runTests();
}
