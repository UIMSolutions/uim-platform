/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.technician;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class TechnicianController : ManageHttpController {
    private ManageTechniciansUseCase usecase;

    this(ManageTechniciansUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/field-service/technicians", &handleList);
        router.get("/api/v1/field-service/technicians/*", &handleGet);
        router.post("/api/v1/field-service/technicians", &handleCreate);
        router.put("/api/v1/field-service/technicians/*", &handleUpdate);
        router.delete_("/api/v1/field-service/technicians/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listTechnicians(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Technicians retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TechnicianId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid technician ID", 400); 

        auto e = usecase.getTechnician(tenantId, id);
        if (e.isNull)
            return errorResponse("Technician not found", 404);

        return successResponse("Technician retrieved successfully", "Retrieved", 200, e.toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        TechnicianDTO dto;
        dto.technicianId = TechnicianId(precheck.id);
        dto.tenantId = tenantId;
        dto.firstName = data.getString("firstName");
        dto.lastName = data.getString("lastName");
        dto.email = data.getString("email");
        dto.phone = data.getString("phone");
        dto.region = data.getString("region");
        dto.address = data.getString("address");
        dto.latitude = data.getString("latitude");
        dto.longitude = data.getString("longitude");
        dto.availabilityStart = data.getString("availabilityStart");
        dto.availabilityEnd = data.getString("availabilityEnd");
        dto.maxWorkload = data.getString("maxWorkload");
        dto.travelRadius = data.getString("travelRadius");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createTechnician(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);

        return successResponse("Technician created successfully", "Created", 201, resp);

    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        TechnicianDTO dto;
        dto.technicianId = TechnicianId(precheck.id);
        dto.tenantId = tenantId;
        dto.firstName = data.getString("firstName");
        dto.lastName = data.getString("lastName");
        dto.email = data.getString("email");
        dto.phone = data.getString("phone");
        dto.region = data.getString("region");
        dto.address = data.getString("address");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateTechnician(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Technician updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TechnicianId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid technician ID", 400);

        auto result = usecase.deleteTechnician(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Technician deleted successfully", "Deleted", 200, responseData);
    }
}
