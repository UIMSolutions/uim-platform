/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.access_control;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class AccessControlController : ManageHttpController {
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
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = accessControls.listAccessControls(tenantId);
        return successResponse("Access controls retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AccessControlId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid access control ID", 400);

        auto e = accessControls.getAccessControl(tenantId, id);
        if (e.isNull)
            return errorResponse("Access control not found", 404);

        return successResponse("Access control retrieved successfully", "Retrieved", 200, e.toJson()
            .set("status", "success")
            .set("statusCode", 200));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        AccessControlDTO dto;
        dto.accessControlId = AccessControlId(data.getString("accessControlId", ""));
        dto.tenantId        = tenantId;
        dto.instanceId      = ServiceInstanceId(data.getString("instanceId", ""));
        dto.cidr            = data.getString("cidr", "");
        dto.description     = data.getString("description", "");
        dto.createdBy       = UserId(data.getString("createdBy", ""));

        auto result = accessControls.createAccessControl(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Access control created successfully", "Created", 201, Json.emptyObject
            .set("id", result.id));
            .set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        AccessControlDTO dto;
        dto.accessControlId = AccessControlId(precheck.id);
        dto.tenantId        = tenantId;
        dto.description     = data.getString("description", "");
        dto.updatedBy       = UserId(data.getString("updatedBy", ""));

        auto result = accessControls.updateAccessControl(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Access control updated successfully", "Updated", 200, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AccessControlId(precheck.id);

        auto result = accessControls.deleteAccessControl(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Access control deleted successfully", "Deleted", 200, Json.emptyObject
            .set("id", result.id));
            .set("statusCode", 200);
    }
}
