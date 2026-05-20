/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.access_control;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class AccessControlController : ManageController {
    private ManageAccessControlsUseCase accessControls;

    this(ManageAccessControlsUseCase accessControls) {
        this.accessControls = accessControls;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/access-controls",   &handleList);
        router.get("/api/v1/redis/access-controls/*", &handleGet);
        router.post("/api/v1/redis/access-controls",  &handleCreate);
        router.put("/api/v1/redis/access-controls/*", &handleUpdate);
        router.delete_("/api/v1/redis/access-controls/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto items = accessControls.listAccessControls(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Access controls retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto id = AccessControlId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid access control ID").set("statusCode", 400);

        auto e = accessControls.getAccessControl(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Access control not found").set("statusCode", 404);

        return e.toJson().set("message", "Access control retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];

        AccessControlDTO dto;
        dto.accessControlId = AccessControlId(data.getString("accessControlId", ""));
        dto.tenantId        = tenantId;
        dto.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
        dto.cidr            = data.getString("cidr", "");
        dto.description     = data.getString("description", "");
        dto.createdBy       = UserId(data.getString("createdBy", ""));

        auto result = accessControls.createAccessControl(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Access control created successfully")
            .set("status", "success")
            .set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];

        AccessControlDTO dto;
        dto.accessControlId = AccessControlId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId        = tenantId;
        dto.description     = data.getString("description", "");
        dto.updatedBy       = UserId(data.getString("updatedBy", ""));

        auto result = accessControls.updateAccessControl(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Access control updated successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto id = AccessControlId(extractIdFromPath(req.requestURI.to!string));

        auto result = accessControls.deleteAccessControl(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 404);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Access control deleted successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
