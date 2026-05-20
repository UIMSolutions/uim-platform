/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.formation;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;
import std.conv  : to;
import std.array : array;
import std.algorithm : map;

@safe:

class FormationController : ManageController {
    private ManageFormationsUseCase _useCase;

    this(ManageFormationsUseCase useCase) { _useCase = useCase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/formations",       &handleList);
        router.get("/api/v1/appevents/formations/*",     &handleGet);
        router.post("/api/v1/appevents/formations",      &handleCreate);
        router.put("/api/v1/appevents/formations/*",     &handleUpdate);
        router.delete_("/api/v1/appevents/formations/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto items = _useCase.listFormations(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message",   "Formations retrieved successfully")
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = FormationId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = _useCase.getFormation(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Formation not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        FormationDTO dto;
        dto.formationId    = FormationId(data.getString("formationId", ""));
        dto.tenantId       = tenantId;
        dto.name           = data.getString("name", "");
        dto.description    = data.getString("description", "");
        dto.globalAccountId = data.getString("globalAccountId", "");
        dto.createdBy      = UserId(data.getString("createdBy", ""));
        auto result = _useCase.createFormation(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Formation created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        FormationDTO dto;
        dto.formationId    = FormationId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId       = tenantId;
        dto.name           = data.getString("name", "");
        dto.description    = data.getString("description", "");
        dto.globalAccountId = data.getString("globalAccountId", "");
        dto.updatedBy      = UserId(data.getString("updatedBy", ""));
        auto result = _useCase.updateFormation(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Formation updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = FormationId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteFormation(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Formation deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
