/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.broker_service;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class BrokerServiceController : ManageController {
    private ManageBrokerServicesUseCase usecase;

    this(ManageBrokerServicesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/broker-services", &handleList);
        router.get("/api/v1/event-mesh/broker-services/*", &handleGet);
        router.post("/api/v1/event-mesh/broker-services", &handleCreate);
        router.put("/api/v1/event-mesh/broker-services/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/broker-services/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listServices(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Broker service list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = usecase.getService(tenantId, BrokerServiceId(id));
            if (e.isNull) {
                writeError(res, 404, "Broker service not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("message", "Broker service retrieved successfully")
                .set("resource", e.toJson);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            BrokerServiceDTO dto;
            dto.serviceId = BrokerServiceId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.region = j.getString("region");
            dto.datacenter = j.getString("datacenter");
            dto.version_ = j.getString("version");
            dto.maxConnections = j.getString("maxConnections");
            dto.maxQueueDepth = j.getString("maxQueueDepth");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.msgVpnName = j.getString("msgVpnName");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createService(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Broker service created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto serviceId = BrokerServiceId(extractIdFromPath(path));
            auto j = req.json;

            BrokerServiceDTO dto;
            dto.tenantId = tenantId;
            dto.serviceId = serviceId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.region = j.getString("region");
            dto.maxConnections = j.getString("maxConnections");
            dto.maxQueueDepth = j.getString("maxQueueDepth");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateService(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Broker service updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BrokerServiceId(extractIdFromPath(path));

            auto result = usecase.deleteService(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Broker service deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
