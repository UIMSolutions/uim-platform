/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_route;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRouteController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listRoutes(tenantId);
            auto list = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TransportRouteprecheck.id);
            auto item = usecase.getRoute(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport route not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            TransportRouteDTO dto;
            dto.routeId = TransportRouteId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.sourceNodeId = data.getString("sourceNodeId");
            dto.destinationNodeId = data.getString("destinationNodeId");
            dto.status = data.getString("status");
            dto.isSequential = data.getBoolean("isSequential");
            dto.sequence = cast(int) data.getLong("sequence");
            dto.createdBy = UserId(data.getString("createdBy"));
            auto result = usecase.createRoute(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport route created"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TransportRouteprecheck.id);
            auto data = precheck.data;
            auto action = data.getString("action");
            if (action == "enable") {
                auto result = usecase.enableRoute(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Route enabled"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "disable") {
                auto result = usecase.disableRoute(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Route disabled"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            TransportRouteDTO dto;
            dto.routeId = id;
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.isSequential = data.getBoolean("isSequential");
            dto.sequence = cast(int) data.getLong("sequence");
            dto.updatedBy = UserId(data.getString("updatedBy"));
            auto result = usecase.updateRoute(dto);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport route updated"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TransportRouteprecheck.id);
            auto result = usecase.deleteRoute(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport route deleted"), 200);
            else writeError(res, 404, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
