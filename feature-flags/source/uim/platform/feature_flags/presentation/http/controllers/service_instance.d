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

mixin(ShowModule!());

@safe:

class ServiceInstanceController {
    private ManageServiceInstancesUseCase useCase;

    this(ManageServiceInstancesUseCase useCase) {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/api/v1/feature-flags/instances", &handleList);
        router.post("/api/v1/feature-flags/instances", &handleCreate);
        router.get("/api/v1/feature-flags/instances/*", &handleGet);
        router.put("/api/v1/feature-flags/instances/*", &handleUpdate);
        router.delete_("/api/v1/feature-flags/instances/*", &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto instances = useCase.listInstances(tenantId);

        auto jarr = Json.emptyArray;
        foreach (inst; instances)
            jarr ~= toJson(inst);

        auto j = Json.emptyObject;
        j["count"] = cast(long)instances.length;
        j["resources"] = jarr;
        res.writeJsonBody(j, cast(int)HTTPStatus.ok);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto body_ = req.json;
        if (body_.type == Json.Type.undefined) {
            writeError(res, cast(int)HTTPStatus.badRequest, "Request body required");
            return;
        }

        CreateServiceInstanceRequest dto;
        dto.name = getString(body_, "name");
        dto.description = getString(body_, "description");
        dto.bindingGuid = getString(body_, "bindingGuid");
        dto.labels = getStringMap(body_, "labels");
        dto.createdBy = getString(body_, "createdBy");

        auto result = useCase.createInstance(dto);
        if (result.hasError) {
            writeError(res, 400, result.message);
            return;
        }

        auto j = Json.emptyObject;
        j["id"] = result.id;
        j["message"] = "Service instance created";
        res.writeJsonBody(j, cast(int)HTTPStatus.created);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto path = req.requestPath.to!string;
        auto id = ServiceInstanceId(extractIdFromPath(path));
        if (id.isNull) {
            writeError(res, 400, "Invalid instance ID");
            return;
        }

        auto inst = useCase.getInstance(tenantId, id);
        if (inst.isNull) {
            writeError(res, 404, "Service instance not found");
            return;
        }

        res.writeJsonBody(toJson(inst), cast(int)HTTPStatus.ok);
    }

    private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto path = req.requestPath.to!string;
        auto id = ServiceInstanceId(extractIdFromPath(path));
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

        auto j = Json.emptyObject;
        j["id"] = result.id;
        return successResponse("Service instance updated successfully", "Updated", 200, j);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto deletedBy = req.query.get("deletedBy", "");
        auto path = req.requestPath.to!string;
        auto id = ServiceInstanceId(extractIdFromPath(path));
        if (id.isNull)
            return errorResponse("Invalid instance ID", 400);

        auto result = useCase.deleteInstance(tenantId, id, deletedBy);
        if (result.hasError) {
            return errorResponse(result.message, 404);
        }

        return successResponse("Service instance deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result
                .id));
    }
}
