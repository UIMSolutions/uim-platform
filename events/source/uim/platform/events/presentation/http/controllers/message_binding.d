/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.message_binding;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessageBindingController : ManageController {
    private ManageMessageBindingsUseCase usecase;

    this(ManageMessageBindingsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/message-bindings",    &handleList);
        router.get("/api/v1/sap-event-mesh/message-bindings/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/message-bindings",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/message-bindings/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/message-bindings/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listBindings(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Message binding list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getBinding(tenantId, MessageBindingId(id));
            if (e.isNull) { writeError(res, 404, "Message binding not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Message binding retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            MessageBindingDTO dto;
            dto.bindingId   = MessageBindingId(precheck.id);
            dto.tenantId    = tenantId;
            dto.clientId    = MessageClientId(j.getString("clientId"));
            dto.serviceId   = MessagingServiceId(j.getString("serviceId"));
            dto.queueId     = QueueId(j.getString("queueId"));
            dto.channelId   = EventChannelId(j.getString("channelId"));
            dto.name        = j.getString("name");
            dto.description = j.getString("description");
            dto.permission  = j.getString("permission");
            dto.bindingType = j.getString("bindingType");
            dto.createdBy   = UserId(j.getString("createdBy"));
            auto result = usecase.createBinding(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Message binding created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto bindingId = MessageBindingprecheck.id);
            auto j = req.json;
            MessageBindingDTO dto;
            dto.tenantId    = tenantId;
            dto.bindingId   = bindingId;
            dto.description = j.getString("description");
            dto.bindingType = j.getString("bindingType");
            dto.updatedBy   = UserId(j.getString("updatedBy"));
            auto result = usecase.updateBinding(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Message binding updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = MessageBindingprecheck.id);
            auto result = usecase.deleteBinding(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Message binding deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
