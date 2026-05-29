/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.ui_component;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class UIComponentController : ManageController {
    private ManageUIComponentsUseCase components;

    this(ManageUIComponentsUseCase components) {
        this.components = components;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/ui-components", &handleList);
        router.get("/api/v1/build-apps/ui-components/*", &handleGet);
        router.post("/api/v1/build-apps/ui-components", &handleCreate);
        router.put("/api/v1/build-apps/ui-components/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/ui-components/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = components.listUIComponents(tenantId);
        auto list = components.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("UI component list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = UIComponentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid UI component ID", 400);

        auto component = components.getUIComponent(tenantId, id);
        if (component.isNull)
            return errorResponse("UI component not found", 404);

        auto responseData = component.toJson();
        return successResponse("UI component retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UIComponentDTO dto;
        dto.uiComponentId = UIComponentId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.category = data.getString("category");
        dto.version_ = data.getString("version");
        dto.properties = data.getString("properties");
        dto.styleProperties = data.getString("styleProperties");
        dto.eventBindings = data.getString("eventBindings");
        dto.dataBindings = data.getString("dataBindings");
        dto.childComponents = data.getString("childComponents");
        dto.iconUrl = data.getString("iconUrl");
        dto.previewUrl = data.getString("previewUrl");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = components.createUIComponent(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("", 0, responseDate);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        UIComponentDTO dto;
        dto.tenantId = tenantId;
        dto.uiComponentId = UIComponentId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString(
            "version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = components.updateUIComponent(dto);
        if (result.hasError)
            return errorResponse(
                result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("", 0, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = UIComponentId(precheck.id);
        if (id.isNull)
            return errorResponse("", 0);

        auto result = components.deleteUIComponent(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("", 0, responseData);
    }
}
