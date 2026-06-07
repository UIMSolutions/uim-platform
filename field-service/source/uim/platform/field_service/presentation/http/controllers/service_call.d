/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.service_call;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

class ServiceCallController : ManageHttpController {
    private ManageServiceCallsUseCase usecase;

    this(ManageServiceCallsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/field-service/service-calls", &handleList);
        router.get("/api/v1/field-service/service-calls/*", &handleGet);
        router.post("/api/v1/field-service/service-calls", &handleCreate);
        router.put("/api/v1/field-service/service-calls/*", &handleUpdate);
        router.delete_("/api/v1/field-service/service-calls/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listServiceCalls(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Service calls retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ServiceCallId(precheck.id);
        auto serviceCall = usecase.getServiceCall(tenantId, id);
        if (serviceCall.isNull)
            return errorResponse("Service call not found", 404);
        return successResponse("Service call retrieved successfully", "Retrieved", 200, serviceCall
                .toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ServiceCallDTO dto;
        dto.serviceCallId = ServiceCallId(precheck.id);
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(data.getString("customerId"));
        dto.equipmentId = EquipmentId(data.getString("equipmentId"));
        dto.subject = data.getString("subject");
        dto.description = data.getString("description");
        dto.serviceType = data.getString("serviceType");
        dto.contactPerson = data.getString("contactPerson");
        dto.contactPhone = data.getString("contactPhone");
        dto.contactEmail = data.getString("contactEmail");
        dto.reportedDate = data.getString("reportedDate");
        dto.dueDate = data.getString("dueDate");
        dto.address = data.getString("address");
        dto.latitude = data.getString("latitude");
        dto.longitude = data.getString("longitude");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createServiceCall(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Service call created successfully", "Created", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        ServiceCallDTO dto;
        dto.serviceCallId = ServiceCallId(precheck.id);
        dto.tenantId = tenantId;
        dto.subject = data.getString("subject");
        dto.description = data.getString("description");
        dto.contactPerson = data.getString("contactPerson");
        dto.contactPhone = data.getString("contactPhone");
        dto.contactEmail = data.getString("contactEmail");
        dto.resolution = data.getString("resolution");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateServiceCall(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Service call updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ServiceCallId(precheck.id);

        auto result = usecase.deleteServiceCall(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service call deleted successfully", 200, responseData);

    }
}
