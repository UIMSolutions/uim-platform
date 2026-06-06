/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.action;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class ActionController : ManageHttpController {
    private ManageActionsUseCase usecase;

    this(ManageActionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/alert-notification/actions", &handleCreate);
        router.get("/api/v1/alert-notification/actions", &handleList);
        router.get("/api/v1/alert-notification/actions/*", &handleGet);
        router.put("/api/v1/alert-notification/actions/*", &handleUpdate);
        router.delete_("/api/v1/alert-notification/actions/*", &handleDelete);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto body_ = req.json;
        CreateActionRequest dto;
        dto.name = body_["name"].to!string;
        dto.description = body_["description"].opt!string("");
        dto.type_ = body_["type"].to!string;
        dto.state = body_["state"].opt!string("ENABLED");
        dto.fallbackAction = body_["fallbackAction"].opt!string("");
        dto.enableDeliveryStatus = body_["enableDeliveryStatus"].opt!bool(false);
        // parse properties object
        auto propsNode = body_["properties"];
        if (propsNode.isObject())
            foreach (k, v; propsNode.byKeyValue())
                dto.properties[k] = v.to!string;
        auto result = usecase.createAction(tenantId, dto);
        if (!result.success) {
            writeError(res, cast(int)HTTPStatus.badRequest, result.message);
            return;
        }
        res.writeBody(result.message, cast(int)HTTPStatus.created, "application/json");
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto result = usecase.listActions(tenantId);
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto result = usecase.getAction(tenantId, ActionId(id));
        if (!result.success) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

     override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;


        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto body_ = req.json;
        UpdateActionRequest dto;
        dto.description = body_["description"].opt!string("");
        dto.state = body_["state"].opt!string("");
        dto.fallbackAction = body_["fallbackAction"].opt!string("");
        dto.enableDeliveryStatus = body_["enableDeliveryStatus"].opt!bool(false);
        auto propsNode = body_["properties"];
        if (propsNode.isObject())
            foreach (k, v; propsNode.byKeyValue())
                dto.properties[k] = v.to!string;
        auto result = usecase.updateAction(tenantId, ActionId(id), dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Action updated successfully", "Updated", 200, responseData);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto result = usecase.deleteAction(tenantId, ActionId(id));
        if (!result.success) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
    }
}
