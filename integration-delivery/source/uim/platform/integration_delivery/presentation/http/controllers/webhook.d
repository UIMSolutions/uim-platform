/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.webhook;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class WebhookController : ManageHttpController {
    private ManageWebhooksUseCase webhooks;

    this(ManageWebhooksUseCase webhooks) {
        this.webhooks = webhooks;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/webhooks", &handleList);
        router.get("/api/v1/integration-delivery/webhooks/*", &handleGet);
        router.post("/api/v1/integration-delivery/webhooks", &handleCreate);
        router.put("/api/v1/integration-delivery/webhooks/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/webhooks/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = webhooks.listWebhooks(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Webhooks retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = WebhookId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid webhook ID").set("statusCode", 400);

        auto e = webhooks.getWebhook(tenantId, id);
        if (e.isNull)
            return errorResponse("Webhook not found", 404);

        return successResponse("Webhook retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        WebhookDTO dto;
        dto.webhookId = WebhookId(data.getString("webhookId", ""));
        dto.tenantId = tenantId;
        dto.secret = data.getString("secret", "");
        dto.callbackUrl = data.getString("callbackUrl", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = webhooks.createWebhook(dto);
        if (result.hasError)
        return errorResponse(result.message, 400);

    return successResponse("Webhook created successfully", "Created", 201, Json.emptyObject.set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = WebhookId(precheck.id);
        if (id.isNull)
        return errorResponse("Invalid webhook ID", 400);

        WebhookDTO dto;
        dto.tenantId = tenantId;
        dto.webhookId = id;
        dto.callbackUrl = data.getString("callbackUrl", "");
        dto.secret = data.getString("secret", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = webhooks.updateWebhook(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Webhook updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = WebhookId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid webhook ID", 400);

        auto result = webhooks.deleteWebhook(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Webhook deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
    }
}
