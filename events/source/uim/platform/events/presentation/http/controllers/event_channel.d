/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.event_channel;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class EventChannelController : PlatformController {
    private ManageEventChannelsUseCase usecase;

    this(ManageEventChannelsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/event-channels",    &handleList);
        router.get("/api/v1/sap-event-mesh/event-channels/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/event-channels",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/event-channels/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/event-channels/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listChannels(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Event channel list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = usecase.getChannel(tenantId, EventChannelId(id));
            if (e.isNull) { writeError(res, 404, "Event channel not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Event channel retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            EventChannelDTO dto;
            dto.channelId          = EventChannelId(j.getString("id"));
            dto.tenantId           = tenantId;
            dto.serviceId          = MessagingServiceId(j.getString("serviceId"));
            dto.name               = j.getString("name");
            dto.description        = j.getString("description");
            dto.channelType        = j.getString("channelType");
            dto.namespace          = j.getString("namespace");
            dto.topicName          = j.getString("topicName");
            dto.asyncapiDefinition = j.getString("asyncapiDefinition");
            dto.maxRetentionPeriod = j.getString("maxRetentionPeriod");
            dto.maxPartitions      = j.getString("maxPartitions");
            dto.createdBy          = UserId(j.getString("createdBy"));
            auto result = usecase.createChannel(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Event channel created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto channelId = EventChannelId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            EventChannelDTO dto;
            dto.tenantId           = tenantId;
            dto.channelId          = channelId;
            dto.description        = j.getString("description");
            dto.asyncapiDefinition = j.getString("asyncapiDefinition");
            dto.maxRetentionPeriod = j.getString("maxRetentionPeriod");
            dto.maxPartitions      = j.getString("maxPartitions");
            dto.updatedBy          = UserId(j.getString("updatedBy"));
            auto result = usecase.updateChannel(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Event channel updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = EventChannelId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteChannel(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Event channel deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
