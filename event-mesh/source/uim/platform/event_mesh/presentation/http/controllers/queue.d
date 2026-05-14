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
    private ManageQueuesUseCase usecase;

    this(ManageQueuesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/queues", &handleList);
        router.get("/api/v1/event-mesh/queues/*", &handleGet);
        router.post("/api/v1/event-mesh/queues", &handleCreate);
        router.put("/api/v1/event-mesh/queues/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/queues/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listQueues(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Queue list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = QueueId(extractIdFromPath(path));

            auto e = usecase.getQueue(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Queue not found");
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
            QueueDTO dto;
            dto.queueId = QueueId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.serviceId = BrokerServiceId(j.getString("brokerServiceId"));
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
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createQueue(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Queue created");

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

            QueueDTO dto;
            dto.queueId = QueueId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.maxMsgSpoolUsage = j.getString("maxMsgSpoolUsage");
            dto.maxBindCount = j.getString("maxBindCount");
            dto.maxMsgSize = j.getString("maxMsgSize");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateQueue(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Queue updated");

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
            auto id = QueueId(extractIdFromPath(path));

            auto result = usecase.deleteQueue(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Queue deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
