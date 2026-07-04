/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.messaging_service;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessagingServiceController : ManageHttpController {
    private ManageMessagingServicesUseCase usecase;

    this(ManageMessagingServicesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/messaging-services", &handleList);
        router.get("/api/v1/sap-event-mesh/messaging-services/*", &handleGet);
        router.post("/api/v1/sap-event-mesh/messaging-services", &handleCreate);
        router.put("/api/v1/sap-event-mesh/messaging-services/*", &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/messaging-services/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listServices(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Messaging service list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = precheck.id;
        auto e = usecase.getService(tenantId, MessagingServiceId(id));
        if (e.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = e.toJson();
        return successResponse("Messaging service retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        MessagingServiceDTO dto;
        dto.serviceId = MessagingServiceId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.namespace = data.getString("namespace");
        dto.plan = data.getString("plan");
        dto.region = data.getString("region");
        dto.datacenter = data.getString("datacenter");
        dto.version_ = data.getString("version");
        dto.maxConnections = data.getString("maxConnections");
        dto.maxQueues = data.getString("maxQueues");
        dto.maxQueueDepth = data.getString("maxQueueDepth");
        dto.maxMessageSize = data.getString("maxMessageSize");
        dto.createdBy = UserId(data.getString("createdBy"));
        auto result = usecase.createService(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Messaging service created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto serviceId = MessagingServiceId(precheck.id);
        auto data = precheck.data;
        MessagingServiceDTO dto;
        dto.tenantId = tenantId;
        dto.serviceId = serviceId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.region = data.getString("region");
        dto.maxConnections = data.getString("maxConnections");
        dto.maxQueues = data.getString("maxQueues");
        dto.maxQueueDepth = data.getString("maxQueueDepth");
        dto.maxMessageSize = data.getString("maxMessageSize");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        auto result = usecase.updateService(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Messaging service updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MessagingServiceId(precheck.id);
        auto result = usecase.deleteService(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Messaging service deleted successfully", "Deleted", 200, responseData);
    }
}
