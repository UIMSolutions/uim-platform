/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.http.controllers.service_instance;

import uim.platform.feature_flags;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPStatus;
import vibe.data.json : Json;
import std.conv : to;
import std.algorithm : map;
import std.array : array;

// mixin(ShowModule!());

@safe:

class ServiceInstanceController : ManageHttpController {
    private ManageServiceInstancesUseCase useCase;

    this(ManageServiceInstancesUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/feature-flags/instances", &handleList);
        router.post("/api/v1/feature-flags/instances", &handleCreate);
        router.get("/api/v1/feature-flags/instances/*", &handleGet);
        router.put("/api/v1/feature-flags/instances/*", &handleUpdate);
        router.delete_("/api/v1/feature-flags/instances/*", &handleDelete);
    }

override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto instances = useCase.listInstances(tenantId).map!(inst => inst.toJson()).array;

        auto j = Json.emptyObject
        .set("count", instances.length)
            .set("resources", instances);
        return successResponse("Service instance list retrieved successfully", "Retrieved", 200, j);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    
        auto data = precheck.data;
        CreateServiceInstanceRequest dto;
        dto.name = getString(data, "name");
        dto.description = getString(data, "description");
        dto.bindingGuid = getString(data, "bindingGuid");
        dto.labels = getStringMap(data, "labels");
        dto.createdBy = getString(data, "createdBy");

        auto result = useCase.createInstance(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service instance created successfully", "Created", 201, responseData);
    }

 override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(extractIdFromPath(path));
        if (id.isNull) {
            writeError(res, 400, "Invalid instance ID");
            return;
        }

        auto inst = useCase.getInstance(tenantId, id);
        if (inst.isNull)
            return errorResponse("Service instance not found", 404);

        return successResponse("Service instance retrieved successfully", "Retrieved", 200, toJson(inst));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid instance ID", 400);

        auto data = precheck.data;
        UpdateServiceInstanceRequest dto;
        dto.description = getString(data, "description");
        dto.labels = getStringMap(data, "labels");
        dto.updatedBy = getString(data, "updatedBy");

        auto result = useCase.updateInstance(tenantId, id, dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service instance updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto deletedBy = req.query.get("deletedBy", "");
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid instance ID", 400);

        auto result = useCase.deleteInstance(tenantId, id, deletedBy);
        if (result.hasError) 
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service instance deleted successfully", "Deleted", 200, responseData);
    }
}
