/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.subscription;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class SubscriptionController : ManageHttpController {
    protected ManageSubscriptionsUseCase usecase;

    this(ManageSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/alert-notification/subscriptions", &handleCreate);
        router.get("/api/v1/alert-notification/subscriptions", &handleList);
        router.get("/api/v1/alert-notification/subscriptions/*", &handleGet);
        router.put("/api/v1/alert-notification/subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/alert-notification/subscriptions/*", &handleDelete);
    }

    protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        CreateSubscriptionRequest dto;
        dto.name = data["name"].to!string;
        dto.description = data["description"].opt!string("");
        dto.state = data["state"].opt!string("ENABLED");
        auto conditionsNode = data["conditions"];
        if (conditionsNode.isArray)
            foreach (v; conditionsNode.byValue)
                dto.conditions ~= v.to!string;

        auto actionsNode = data["actions"];
        if (actionsNode.isArray)
            foreach (v; actionsNode.byValue)
                dto.actions ~= v.to!string;

        auto result = usecase.createSubscription(tenantId, dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Subscription created successfully", 201, responseData);
    }

    mixin(HandleTemplate!("handleCreate", "createHandler"));

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto result = usecase.listSubscriptions(tenantId);
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto result = usecase.getSubscription(tenantId, id);
        if (result.hasError) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto data = req.json;
        UpdateSubscriptionRequest dto;
        dto.description = data["description"].opt!string("");
        dto.state = data["state"].opt!string("");
        auto conditionsNode = data["conditions"];
        if (conditionsNode.isArray)
            foreach (v; conditionsNode.byValue)
                dto.conditions ~= v.to!string;
        auto actionsNode = data["actions"];
        if (actionsNode.isArray)
            foreach (v; actionsNode.byValue)
                dto.actions ~= v.to!string;
        auto result = usecase.updateSubscription(tenantId, id, dto);
        if (result.hasError) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeBody(result.message, cast(int)HTTPStatus.ok, "application/json");
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto result = usecase.deleteSubscription(tenantId, id);
        if (result.hasError) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
    }
}
