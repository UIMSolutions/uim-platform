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
    private ManageMeshBridgesUseCase uc;

    this(ManageMeshBridgesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/bridges", &handleList);
        router.get("/api/v1/event-mesh/bridges/*", &handleGet);
        router.post("/api/v1/event-mesh/bridges", &handleCreate);
        router.put("/api/v1/event-mesh/bridges/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/bridges/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => meshBridgeToJson(e)).array;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

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
            auto e = uc.getById(MeshBridgeId(id));
            if (e.isNull) { writeError(res, 404, "Mesh bridge not found"); return; }
            res.writeJsonBody(meshBridgeToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            MeshBridgeDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.sourceBrokerId = j.getString("sourceBrokerId");
            dto.targetBrokerId = j.getString("targetBrokerId");
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
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Mesh bridge created"));

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
            MeshBridgeDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.remoteAddress = j.getString("remoteAddress");
            dto.topicSubscriptions = j.getString("topicSubscriptions");
            dto.queueBindings = j.getString("queueBindings");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Mesh bridge updated"));

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
            auto result = uc.remove(MeshBridgeId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", Json("Mesh bridge deleted"));

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
