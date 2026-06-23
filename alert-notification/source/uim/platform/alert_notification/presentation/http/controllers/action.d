/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.action;

import uim.platform.alert_notification;

// mixin(ShowModule!());

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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CreateActionRequest dto;
        dto.name = data.getString("name");
        dto.description = data.getString("description", "");
        dto.type_ = data.getString("type");
        dto.state = data.getString("state", "ENABLED");
        dto.fallbackAction = data.getString("fallbackAction", "");
        dto.enableDeliveryStatus = data.getBool("enableDeliveryStatus", false);
        // parse properties object
        auto propsNode = data["properties"];
        if (propsNode.isObject())
            foreach (k, v; propsNode.byKeyValue())
                dto.properties[k] = v.to!string;

        auto result = usecase.createAction(tenantId, dto);
        if (!result.success)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Action created successfully", "Created", 201, responseData);
    }
    
    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto result = usecase.listActions(tenantId);
        if (!result.success)
            return errorResponse(result.message, 400);

        return successResponse("Actions retrieved successfully", "Retrieved", 200, result.data);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ActionId(req.requestPath.to!string.split("/")[$ - 1]);
        if (id.isNull)
            return errorResponse("Invalid action ID", 400);

        auto result = usecase.getAction(tenantId, id);
        if (!result.success)
            return errorResponse(result.message, 404);

        return successResponse("Action retrieved successfully", "Retrieved", 200, result.data);
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

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ActionId(req.requestPath.to!string.split("/")[$ - 1]);
        if (id.isNull)
            return errorResponse("Invalid action ID", 400);

        auto result = usecase.deleteAction(tenantId, id);
        if (!result.success)
            return errorResponse(result.message, 404);

        return successResponse("Action deleted successfully", "Deleted", 204, Json.emptyObject);
    }
}
