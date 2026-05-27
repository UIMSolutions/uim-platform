/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.event_channel;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class EventChannelController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listChannels(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Event channel list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getChannel(tenantId, EventChannelId(id));
            if (e.isNull) { writeError(res, 404, "Event channel not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Event channel retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            EventChannelDTO dto;
            dto.channelId          = EventChannelId(precheck.id);
            dto.tenantId           = tenantId;
            dto.serviceId          = MessagingServiceId(data.getString("serviceId"));
            dto.name               = data.getString("name");
            dto.description        = data.getString("description");
            dto.channelType        = data.getString("channelType");
            dto.namespace          = data.getString("namespace");
            dto.topicName          = data.getString("topicName");
            dto.asyncapiDefinition = data.getString("asyncapiDefinition");
            dto.maxRetentionPeriod = data.getString("maxRetentionPeriod");
            dto.maxPartitions      = data.getString("maxPartitions");
            dto.createdBy          = UserId(data.getString("createdBy"));
            auto result = usecase.createChannel(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Event channel created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto channelId = EventChannelprecheck.id);
            auto data = precheck.data;
            EventChannelDTO dto;
            dto.tenantId           = tenantId;
            dto.channelId          = channelId;
            dto.description        = data.getString("description");
            dto.asyncapiDefinition = data.getString("asyncapiDefinition");
            dto.maxRetentionPeriod = data.getString("maxRetentionPeriod");
            dto.maxPartitions      = data.getString("maxPartitions");
            dto.updatedBy          = UserId(data.getString("updatedBy"));
            auto result = usecase.updateChannel(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Event channel updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = EventChannelprecheck.id);
            auto result = usecase.deleteChannel(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Event channel deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
