/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.mesh_bridge;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MeshBridgeController : PlatformController {
    private ManageMeshBridgesUseCase usecase;

    this(ManageMeshBridgesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/event-mesh/bridges", &handleList);
        router.get("/api/v1/event-mesh/bridges/*", &handleGet);
        router.post("/api/v1/event-mesh/bridges", &handleCreate);
        router.put("/api/v1/event-mesh/bridges/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/bridges/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listBridges(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Mesh bridge list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = MeshBridgeId(extractIdFromPath(path));

            auto e = usecase.getBridge(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Mesh bridge not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            MeshBridgeDTO dto;
            dto.bridgeId = MeshBridgeId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.sourceServiceId = BrokerServiceId(j.getString("sourceServiceId"));
            dto.targetServiceId = BrokerServiceId(j.getString("targetServiceId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.remoteAddress = j.getString("remoteAddress");
            dto.remoteVpnName = j.getString("remoteVpnName");
            dto.topicSubscriptions = j.getString("topicSubscriptions");
            dto.queueBindings = j.getString("queueBindings");
            dto.tlsEnabled = j.getString("tlsEnabled");
            dto.compressedDataEnabled = j.getString("compressedDataEnabled");
            dto.maxTtl = j.getString("maxTtl");
            dto.retryCount = j.getString("retryCount");
            dto.retryDelay = j.getString("retryDelay");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createBridge(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Mesh bridge created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            MeshBridgeDTO dto;
            dto.bridgeId = MeshBridgeId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.remoteAddress = j.getString("remoteAddress");
            dto.topicSubscriptions = j.getString("topicSubscriptions");
            dto.queueBindings = j.getString("queueBindings");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateBridge(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Mesh bridge updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto bridgeId = MeshBridgeId(extractIdFromPath(path));
            auto result = usecase.deleteBridge(tenantId, bridgeId);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Mesh bridge deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
