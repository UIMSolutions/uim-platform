/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.messaging_service;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessagingServiceController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listServices(tenantId);
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Messaging service list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getService(tenantId, MessagingServiceId(id));
            if (e.isNull) { writeError(res, 404, "Messaging service not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Messaging service retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            MessagingServiceDTO dto;
            dto.serviceId   = MessagingServiceId(precheck.id);
            dto.tenantId    = tenantId;
            dto.name        = data.getString("name");
            dto.description = data.getString("description");
            dto.namespace   = data.getString("namespace");
            dto.plan        = data.getString("plan");
            dto.region      = data.getString("region");
            dto.datacenter  = data.getString("datacenter");
            dto.version_    = data.getString("version");
            dto.maxConnections  = data.getString("maxConnections");
            dto.maxQueues       = data.getString("maxQueues");
            dto.maxQueueDepth   = data.getString("maxQueueDepth");
            dto.maxMessageSize  = data.getString("maxMessageSize");
            dto.createdBy   = UserId(data.getString("createdBy"));
            auto result = usecase.createService(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Messaging service created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId  = req.getTenantId;
            auto serviceId = MessagingServiceprecheck.id);
            auto j = req.json;
            MessagingServiceDTO dto;
            dto.tenantId    = tenantId;
            dto.serviceId   = serviceId;
            dto.name        = data.getString("name");
            dto.description = data.getString("description");
            dto.region      = data.getString("region");
            dto.maxConnections = data.getString("maxConnections");
            dto.maxQueues    = data.getString("maxQueues");
            dto.maxQueueDepth = data.getString("maxQueueDepth");
            dto.maxMessageSize = data.getString("maxMessageSize");
            dto.updatedBy   = UserId(data.getString("updatedBy"));
            auto result = usecase.updateService(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Messaging service updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = MessagingServiceprecheck.id);
            auto result = usecase.deleteService(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Messaging service deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
