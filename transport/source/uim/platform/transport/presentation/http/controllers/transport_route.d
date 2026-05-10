/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_route;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRouteController : PlatformController {
    private ManageTransportRoutesUseCase usecase;

    this(ManageTransportRoutesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/routes", &handleList);
        router.get("/api/v1/transport/routes/*", &handleGet);
        router.post("/api/v1/transport/routes", &handleCreate);
        router.put("/api/v1/transport/routes/*", &handleUpdate);
        router.delete_("/api/v1/transport/routes/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listRoutes(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRouteId(extractIdFromPath(req.requestURI.to!string));
            auto item = usecase.getRoute(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport route not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            TransportRouteDTO dto;
            dto.routeId = TransportRouteId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.sourceNodeId = j.getString("sourceNodeId");
            dto.destinationNodeId = j.getString("destinationNodeId");
            dto.status = j.getString("status");
            dto.isSequential = j.getBool("isSequential");
            dto.sequence = cast(int) j.getLong("sequence");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.createRoute(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport route created"), 201);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRouteId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            auto action = j.getString("action");
            if (action == "enable") {
                auto result = usecase.enableRoute(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Route enabled"), 200);
                else writeError(res, 400, result.error);
                return;
            }
            if (action == "disable") {
                auto result = usecase.disableRoute(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Route disabled"), 200);
                else writeError(res, 400, result.error);
                return;
            }
            TransportRouteDTO dto;
            dto.routeId = id;
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.isSequential = j.getBool("isSequential");
            dto.sequence = cast(int) j.getLong("sequence");
            dto.updatedBy = UserId(j.getString("updatedBy"));
            auto result = usecase.updateRoute(dto);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport route updated"), 200);
            else writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRouteId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteRoute(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport route deleted"), 200);
            else writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
