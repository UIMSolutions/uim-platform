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
    private ManageSubscriptionsUseCase usecase;

    this(ManageSubscriptionsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post  ("/api/v1/alert-notification/subscriptions",   &handleCreate);
        router.get   ("/api/v1/alert-notification/subscriptions",   &handleList);
        router.get   ("/api/v1/alert-notification/subscriptions/*", &handleGet);
        router.put   ("/api/v1/alert-notification/subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/alert-notification/subscriptions/*", &handleDelete);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto body_    = req.json;
        CreateSubscriptionRequest dto;
        dto.name        = body_["name"].to!string;
        dto.description = body_["description"].opt!string("");
        dto.state       = body_["state"].opt!string("ENABLED");
        auto conditionsNode = body_["conditions"];
        if (conditionsNode.isArray)
            foreach (v; conditionsNode.byValue) dto.conditions ~= v.to!string;
        auto actionsNode = body_["actions"];
        if (actionsNode.isArray)
            foreach (v; actionsNode.byValue) dto.actions ~= v.to!string;
        auto result = usecase.createSubscription(tenantId, dto);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.badRequest, result.message); return; }
        res.writeBody(result.message, cast(int)HTTPStatus.created, "application/json");
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto result   = usecase.listSubscriptions(tenantId);
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id       = req.requestPath.to!string.split("/")[$-1];
        auto result   = usecase.getSubscription(tenantId, id);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id       = req.requestPath.to!string.split("/")[$-1];
        auto body_    = req.json;
        UpdateSubscriptionRequest dto;
        dto.description = body_["description"].opt!string("");
        dto.state       = body_["state"].opt!string("");
        auto conditionsNode = body_["conditions"];
        if (conditionsNode.isArray)
            foreach (v; conditionsNode.byValue) dto.conditions ~= v.to!string;
        auto actionsNode = body_["actions"];
        if (actionsNode.isArray)
            foreach (v; actionsNode.byValue) dto.actions ~= v.to!string;
        auto result = usecase.updateSubscription(tenantId, id, dto);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeBody(result.message, cast(int)HTTPStatus.ok, "application/json");
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id       = req.requestPath.to!string.split("/")[$-1];
        auto result   = usecase.deleteSubscription(tenantId, id);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
    }
}
