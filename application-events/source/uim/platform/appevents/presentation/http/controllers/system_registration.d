/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.system_registration;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.system_registrations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.system_type;
import uim.platform.appevents.domain.enums.system_status;
import std.conv : to;
import std.array : array;
import std.algorithm : map;

@safe:

class SystemRegistrationController : ManageHttpController {
    private ManageSystemRegistrationsUseCase _useCase;

    this(ManageSystemRegistrationsUseCase useCase) {
        _useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/appevents/systems", &handleList);
        router.get("/api/v1/appevents/systems/*", &handleGet);
        router.post("/api/v1/appevents/systems", &handleCreate);
        router.delete_("/api/v1/appevents/systems/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = _useCase.listSystemRegistrations(tenantId).map!(e => e.toJson()).array.toJson;

        return successResponse("System registrations retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;
            
        auto tenantId = precheck.tenantId;
        auto id = SystemRegistrationId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);

        auto e = _useCase.getSystemRegistration(tenantId, id);
        if (e.isNull)
            return errorResponse("System registration not found", 404);

        return successResponse("System registration retrieved successfully", "OK", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        SystemRegistrationDTO dto;
        dto.registrationId = SystemRegistrationId(data.getString("registrationId", ""));
        dto.tenantId = tenantId;
        dto.formationId = FormationId(data.getString("formationId", ""));
        dto.systemId = data.getString("systemId", "");
        dto.systemType = data.getString("systemType", "producer").to!SystemType;
        dto.systemUrl = data.getString("systemUrl", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));
        auto result = _useCase.registerSystem(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("System registered successfully", "Created", 201, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;
        
        auto tenantId = precheck.tenantId;
        auto id = SystemRegistrationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid system registration ID", 400);

        auto result = _useCase.unregisterSystem(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("System unregistered successfully", "Deleted", 200, Json.emptyObject.set("id", result.id)); 
    }
}
