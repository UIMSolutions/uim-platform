/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.equipment;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

class EquipmentController : ManageHttpController {
    private ManageEquipmentUseCase usecase;

    this(ManageEquipmentUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/field-service/equipment", &handleList);
        router.get("/api/v1/field-service/equipment/*", &handleGet);
        router.post("/api/v1/field-service/equipment", &handleCreate);
        router.put("/api/v1/field-service/equipment/*", &handleUpdate);
        router.delete_("/api/v1/field-service/equipment/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listEquipments(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Equipment list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EquipmentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid equipment ID", 400);

        auto equipment = usecase.getEquipment(tenantId, id);
        if (equipment.isNull)
            return errorResponse("Equipment not found", 404);

        return successResponse("Equipment retrieved successfully", "Retrieved", 200, equipment
                .toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        EquipmentDTO dto;
        dto.equipmentId = EquipmentId(precheck.id);
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(data.getString("customerId"));
        dto.serialNumber = data.getString("serialNumber");
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.equipmentType = data.getString("equipmentType");
        dto.manufacturer = data.getString("manufacturer");
        dto.model = data.getString("model");
        dto.installationDate = data.getString("installationDate");
        dto.warrantyEndDate = data.getString("warrantyEndDate");
        dto.locationAddress = data.getString("locationAddress");
        dto.latitude = data.getString("latitude");
        dto.longitude = data.getString("longitude");
        dto.measuringPoint = data.getString("measuringPoint");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createEquipment(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Equipment created successfully", "Created", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EquipmentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid equipment ID", 400);

        auto data = precheck.data;
        EquipmentDTO dto;
        dto.equipmentId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.manufacturer = data.getString("manufacturer");
        dto.model = data.getString("model");
        dto.locationAddress = data.getString("locationAddress");
        dto.lastServiceDate = data.getString("lastServiceDate");
        dto.nextServiceDate = data.getString("nextServiceDate");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateEquipment(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Equipment updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EquipmentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid equipment ID", 400);

        auto result = usecase.deleteEquipment(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Equipment deleted successfully", "Deleted", 200, resp);
    }
}
