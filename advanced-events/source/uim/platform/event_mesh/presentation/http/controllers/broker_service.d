/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.broker_service;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class BrokerServiceController : ManageController {
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
      .set("resources", jarr);

    return successResponse("Broker service list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = req.requestURI.to!string;
    auto id = BrokerServiceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid broker service ID", "BadRequest", 400);

    auto service = usecase.getService(tenantId, id);
    if (service.isNull)
      return errorResponse("Broker service not found", "NotFound", 404);

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

    BrokerServiceDTO dto;
    dto.serviceId = BrokerServiceId(precheck.id);
    dto.tenantId = tenantId;
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
    if (service.isNull)
      return errorResponse("Failed to create broker service", "BadRequest", 400);

    auto resp = Json.emptyObject
      .set("id", service.id);

    return successResponse("Broker service created successfully", "Created", 201, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = req.requestURI.to!string;
    auto id = BrokerServiceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid broker service ID", "BadRequest", 400);

    auto data = precheck.data;

    BrokerServiceDTO dto;
    dto.tenantId = tenantId;
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
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Broker service updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = req.requestURI.to!string;
    auto id = BrokerServiceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid broker service ID", 400);

    auto result = usecase.deleteService(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("message", "Broker service deleted");

    return successResponse("Broker service deleted successfully", "Deleted", 200, resp);
  }
}
