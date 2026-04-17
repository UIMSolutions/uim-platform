/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.broker_service;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class BrokerServiceController : PlatformController {
    private ManageBrokerServicesUseCase uc;

    this(ManageBrokerServicesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/broker-services", &handleList);
        router.get("/api/v1/event-mesh/broker-services/*", &handleGet);
        router.post("/api/v1/event-mesh/broker-services", &handleCreate);
        router.put("/api/v1/event-mesh/broker-services/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/broker-services/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= brokerServiceToJson(e);
            auto resp = Json.emptyObject;
            resp["count"] = Json(items.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(BrokerServiceId(id));
            if (e is null) { writeError(res, 404, "Broker service not found"); return; }
            res.writeJsonBody(brokerServiceToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            BrokerServiceDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.region = j.getString("region");
            dto.datacenter = j.getString("datacenter");
            dto.version_ = j.getString("version");
            dto.maxConnections = j.getString("maxConnections");
            dto.maxQueueDepth = j.getString("maxQueueDepth");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.msgVpnName = j.getString("msgVpnName");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Broker service created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            BrokerServiceDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.region = j.getString("region");
            dto.maxConnections = j.getString("maxConnections");
            dto.maxQueueDepth = j.getString("maxQueueDepth");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Broker service updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(BrokerServiceId(id));
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Broker service deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
