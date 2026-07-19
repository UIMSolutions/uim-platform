/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.service_binding;

import uim.platform.application_studio;
mixin(ShowModule!());

@safe:

class ServiceBindingController : ManageHttpController {
    private ManageServiceBindingsUseCase usecase;

    this(ManageServiceBindingsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/service-bindings", &handleList);
        router.get("/api/v1/application-studio/service-bindings/*", &handleGet);
        router.post("/api/v1/application-studio/service-bindings", &handleCreate);
        router.put("/api/v1/application-studio/service-bindings/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/service-bindings/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listServiceBindings(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Service binding list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceBindingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service binding ID", 400);

        auto binding = usecase.getServiceBinding(tenantId, id);
        if (binding.isNull)
            return errorResponse("Service binding not found", 404);

        auto responseData = binding.toJson();
        return successResponse("Service binding retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ServiceBindingDTO dto;
        dto.bindingId = ServiceBindingId(precheck.id);
        dto.tenantId = tenantId;
        dto.spaceId = DevSpaceId(data.getString("devSpaceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.serviceUrl = data.getString("serviceUrl");
        dto.servicePath = data.getString("servicePath");
        dto.authType = data.getString("authType");
        dto.credentials = data.getString("credentials");
        dto.systemAlias = data.getString("systemAlias");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createServiceBinding(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service binding created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceBindingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service binding ID", 400);

        auto data = precheck.data;
        ServiceBindingDTO dto;
        dto.tenantId = tenantId;
        dto.bindingId = ServiceBindingId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.serviceUrl = data.getString("serviceUrl");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateServiceBinding(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service binding updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceBindingId(precheck.id);

        auto result = usecase.deleteServiceBinding(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service binding deleted successfully", "Deleted", 200, responseData);
    }
}
