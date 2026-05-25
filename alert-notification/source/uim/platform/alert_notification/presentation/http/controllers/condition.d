/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.condition;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class ConditionController : ManageController {
    private ManageConditionsUseCase usecase;

    this(ManageConditionsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post  ("/api/v1/alert-notification/conditions",   &handleCreate);
        router.get   ("/api/v1/alert-notification/conditions",   &handleList);
        router.get   ("/api/v1/alert-notification/conditions/*", &handleGet);
        router.put   ("/api/v1/alert-notification/conditions/*", &handleUpdate);
        router.delete_("/api/v1/alert-notification/conditions/*", &handleDelete);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        import std.conv : to;
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto body_    = req.json;
        CreateConditionRequest dto;
        dto.name          = body_["name"].to!string;
        dto.description   = body_["description"].opt!string("");
        dto.propertyKey   = body_["propertyKey"].to!string;
        dto.predicate     = body_["predicate"].to!string;
        dto.propertyValue = body_["propertyValue"].to!string;
        dto.mandatory     = body_["mandatory"].opt!bool(false);
        auto result = usecase.createCondition(tenantId, dto);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.badRequest, result.message); return; }
        res.writeBody(result.message, cast(int)HTTPStatus.created, "application/json");
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto result   = usecase.listConditions(tenantId);
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        import std.conv : to;
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto id       = req.requestPath.to!string.pathId;
        auto result   = usecase.getCondition(tenantId, id);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        import std.conv : to;
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto id       = req.requestPath.to!string.pathId;
        auto body_    = req.json;
        UpdateConditionRequest dto;
        dto.description   = body_["description"].opt!string("");
        dto.propertyKey   = body_["propertyKey"].opt!string("");
        dto.predicate     = body_["predicate"].opt!string("");
        dto.propertyValue = body_["propertyValue"].opt!string("");
        dto.mandatory     = body_["mandatory"].opt!bool(false);
        auto result = usecase.updateCondition(tenantId, id, dto);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeBody(result.message, cast(int)HTTPStatus.ok, "application/json");
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        import std.conv : to;
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto id       = req.requestPath.to!string.pathId;
        auto result   = usecase.deleteCondition(tenantId, id);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.notFound, result.message); return; }
        res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
    }
}
