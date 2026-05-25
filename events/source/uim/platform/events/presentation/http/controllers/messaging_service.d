/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.messaging_service;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessagingServiceController : PlatformController {
    private ManageMessagingServicesUseCase usecase;

    this(ManageMessagingServicesUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/messaging-services",    &handleList);
        router.get("/api/v1/sap-event-mesh/messaging-services/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/messaging-services",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/messaging-services/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/messaging-services/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listServices(tenantId);
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Messaging service list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = usecase.getService(tenantId, MessagingServiceId(id));
            if (e.isNull) { writeError(res, 404, "Messaging service not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Messaging service retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            MessagingServiceDTO dto;
            dto.serviceId   = MessagingServiceId(j.getString("id"));
            dto.tenantId    = tenantId;
            dto.name        = j.getString("name");
            dto.description = j.getString("description");
            dto.namespace   = j.getString("namespace");
            dto.plan        = j.getString("plan");
            dto.region      = j.getString("region");
            dto.datacenter  = j.getString("datacenter");
            dto.version_    = j.getString("version");
            dto.maxConnections  = j.getString("maxConnections");
            dto.maxQueues       = j.getString("maxQueues");
            dto.maxQueueDepth   = j.getString("maxQueueDepth");
            dto.maxMessageSize  = j.getString("maxMessageSize");
            dto.createdBy   = UserId(j.getString("createdBy"));
            auto result = usecase.createService(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Messaging service created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId  = req.getTenantId;
            auto serviceId = MessagingServiceId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            MessagingServiceDTO dto;
            dto.tenantId    = tenantId;
            dto.serviceId   = serviceId;
            dto.name        = j.getString("name");
            dto.description = j.getString("description");
            dto.region      = j.getString("region");
            dto.maxConnections = j.getString("maxConnections");
            dto.maxQueues    = j.getString("maxQueues");
            dto.maxQueueDepth = j.getString("maxQueueDepth");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.updatedBy   = UserId(j.getString("updatedBy"));
            auto result = usecase.updateService(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Messaging service updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = MessagingServiceId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteService(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Messaging service deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
