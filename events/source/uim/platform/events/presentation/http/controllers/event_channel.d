/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.event_channel;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class EventChannelController : ManageHttpController {
    private ManageEventChannelsUseCase usecase;

    this(ManageEventChannelsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/event-channels", &handleList);
        router.get("/api/v1/sap-event-mesh/event-channels/*", &handleGet);
        router.post("/api/v1/sap-event-mesh/event-channels", &handleCreate);
        router.put("/api/v1/sap-event-mesh/event-channels/*", &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/event-channels/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listChannels(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Event channel list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventChannelId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event channel ID", 400);

        auto e = usecase.getChannel(tenantId, EventChannelId(id));
        if (e.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = item.toJson();
        return successResponse("Event channel retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventChannelId(precheck.id);
        if (!id.isNull)
            return errorResponse("ID should not be provided for creation", 400);

        auto data = precheck.data;
        EventChannelDTO dto;
        // dto.channelId = EventChannelId(precheck.id);
        dto.tenantId = tenantId;
        dto.serviceId = MessagingServiceId(data.getString("serviceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.channelType = data.getString("channelType");
        dto.namespace = data.getString("namespace");
        dto.topicName = data.getString("topicName");
        dto.asyncapiDefinition = data.getString("asyncapiDefinition");
        dto.maxRetentionPeriod = data.getString("maxRetentionPeriod");
        dto.maxPartitions = data.getString("maxPartitions");
        dto.createdBy = UserId(data.getString("createdBy"));
        auto result = usecase.createChannel(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Event channel created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventChannelId(precheck.id);
        if (channelId.isNull)
            return errorResponse("Invalid event channel ID", 400);

        auto data = precheck.data;
        EventChannelDTO dto;
        dto.tenantId = tenantId;
        dto.channelId = id;
        dto.description = data.getString("description");
        dto.asyncapiDefinition = data.getString("asyncapiDefinition");
        dto.maxRetentionPeriod = data.getString("maxRetentionPeriod");
        dto.maxPartitions = data.getString("maxPartitions");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        auto result = usecase.updateChannel(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Event channel updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventChannelId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event channel ID", 400);

        auto result = usecase.deleteChannel(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Event channel deleted successfully", "Deleted", 200, responseData);
    }
}
