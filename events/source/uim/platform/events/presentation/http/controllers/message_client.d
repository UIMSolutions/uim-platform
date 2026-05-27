/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.message_client;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessageClientController : ManageController {
    private ManageMessageClientsUseCase usecase;

    this(ManageMessageClientsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/message-clients",    &handleList);
        router.get("/api/v1/sap-event-mesh/message-clients/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/message-clients",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/message-clients/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/message-clients/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listClients(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Message client list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getClient(tenantId, MessageClientId(id));
            if (e.isNull) { writeError(res, 404, "Message client not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Message client retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            MessageClientDTO dto;
            dto.clientId           = MessageClientId(precheck.id);
            dto.tenantId           = tenantId;
            dto.serviceId          = MessagingServiceId(data.getString("serviceId"));
            dto.name               = data.getString("name");
            dto.description        = data.getString("description");
            dto.protocol           = data.getString("protocol");
            dto.xsappname          = data.getString("xsappname");
            dto.namespace          = data.getString("namespace");
            dto.permittedNamespace = data.getString("permittedNamespace");
            dto.createdBy          = UserId(data.getString("createdBy"));
            auto result = usecase.createClient(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Message client created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto clientId = MessageClientprecheck.id);
            auto data = precheck.data;
            MessageClientDTO dto;
            dto.tenantId           = tenantId;
            dto.clientId           = clientId;
            dto.name               = data.getString("name");
            dto.description        = data.getString("description");
            dto.namespace          = data.getString("namespace");
            dto.permittedNamespace = data.getString("permittedNamespace");
            dto.updatedBy          = UserId(data.getString("updatedBy"));
            auto result = usecase.updateClient(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Message client updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = MessageClientprecheck.id);
            auto result = usecase.deleteClient(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Message client deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
