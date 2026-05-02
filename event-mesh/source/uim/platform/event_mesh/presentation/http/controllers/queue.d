/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.queue;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class QueueController : PlatformController {
    private ManageQueuesUseCase uc;

    this(ManageQueuesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/queues", &handleList);
        router.get("/api/v1/event-mesh/queues/*", &handleGet);
        router.post("/api/v1/event-mesh/queues", &handleCreate);
        router.put("/api/v1/event-mesh/queues/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/queues/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => queueToJson(e)).array;
            
            auto resp = Json.emptyObject
              .set("count", Json(items.length))
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
            auto e = uc.getById(QueueId(id));
            if (e.isNull) { writeError(res, 404, "Queue not found"); return; }
            res.writeJsonBody(queueToJson(e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            QueueDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.brokerServiceId = j.getString("brokerServiceId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.maxMsgSpoolUsage = j.getString("maxMsgSpoolUsage");
            dto.maxBindCount = j.getString("maxBindCount");
            dto.maxMsgSize = j.getString("maxMsgSize");
            dto.maxRedeliveryCount = j.getString("maxRedeliveryCount");
            dto.maxTtl = j.getString("maxTtl");
            dto.deadMessageQueue = j.getString("deadMessageQueue");
            dto.owner = j.getString("owner");
            dto.permission = j.getString("permission");
            dto.egressEnabled = j.getString("egressEnabled");
            dto.ingressEnabled = j.getString("ingressEnabled");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Queue created"));

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
            QueueDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.maxMsgSpoolUsage = j.getString("maxMsgSpoolUsage");
            dto.maxBindCount = j.getString("maxBindCount");
            dto.maxMsgSize = j.getString("maxMsgSize");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Queue updated"));
                  
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
            auto result = uc.remove(QueueId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", Json("Queue deleted"));
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
