/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class WebhookController : ManageController {
    private ManageWebhooksUseCase usecase;

    this(ManageWebhooksUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/webhooks",    &handleList);
        router.get("/api/v1/sap-event-mesh/webhooks/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/webhooks",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/webhooks/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/webhooks/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listWebhooks(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Webhook list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = usecase.getWebhook(tenantId, WebhookId(id));
            if (e.isNull) { writeError(res, 404, "Webhook not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Webhook retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            WebhookDTO dto;
            dto.webhookId        = WebhookId(j.getString("id"));
            dto.tenantId         = tenantId;
            dto.serviceId        = MessagingServiceId(j.getString("serviceId"));
            dto.subscriptionId   = QueueSubscriptionId(j.getString("subscriptionId"));
            dto.name             = j.getString("name");
            dto.description      = j.getString("description");
            dto.url              = j.getString("url");
            dto.headers          = j.getString("headers");
            dto.exemptHandshake  = j.getBool("exemptHandshake");
            dto.authenticationType = j.getString("authenticationType");
            dto.credentialsType  = j.getString("credentialsType");
            dto.credentialGrant  = j.getString("credentialGrant");
            dto.tokenUrl         = j.getString("tokenUrl");
            dto.clientId         = j.getString("clientId");
            dto.pushInterval     = j.getString("pushInterval");
            dto.deliveryMode     = j.getString("deliveryMode");
            dto.maxParallelity   = j.getString("maxParallelity");
            dto.createdBy        = UserId(j.getString("createdBy"));
            auto result = usecase.createWebhook(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Webhook created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId  = req.getTenantId;
            auto webhookId = WebhookId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            WebhookDTO dto;
            dto.tenantId       = tenantId;
            dto.webhookId      = webhookId;
            dto.url            = j.getString("url");
            dto.description    = j.getString("description");
            dto.headers        = j.getString("headers");
            dto.pushInterval   = j.getString("pushInterval");
            dto.maxParallelity = j.getString("maxParallelity");
            dto.updatedBy      = UserId(j.getString("updatedBy"));
            auto result = usecase.updateWebhook(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Webhook updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = WebhookId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteWebhook(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Webhook deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
