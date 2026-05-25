/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.replication;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class ReplicationController : ManageController {
    private ManageReplicationsUseCase usecase;

    this(ManageReplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/masterdata-governance/replications", &handleList);
        router.get("/api/v1/masterdata-governance/replications/*", &handleGet);
        router.post("/api/v1/masterdata-governance/replications", &handleCreate);
        router.put("/api/v1/masterdata-governance/replications/*", &handleUpdate);
        router.delete_("/api/v1/masterdata-governance/replications/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listReplications(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ReplicationId(extractIdFromPath(path));
            auto rep = usecase.getReplication(tenantId, id);
            if (rep.isNull) { writeError(res, 404, "Replication not found"); return; }
            res.writeJsonBody(rep.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ReplicationDTO dto;
            dto.replicationId = ReplicationId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.businessPartnerId = BusinessPartnerId(j.getString("businessPartnerId"));
            dto.targetSystem = j.getString("targetSystem");
            dto.targetSystemType = j.getString("targetSystemType");
            dto.replicationType = j.getString("replicationType");
            dto.scheduledAt = j.getLong("scheduledAt");
            dto.replicatedFields = j.getString("replicatedFields");
            dto.maxRetries = j.getInteger("maxRetries");
            dto.correlationId = j.getString("correlationId");
            dto.batchId = j.getString("batchId");
            dto.triggeredBy = UserId(j.getString("triggeredBy"));

            auto result = usecase.createReplication(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Replication created"), 201);
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
            auto j = req.json;
            auto id = ReplicationId(extractIdFromPath(path));
            auto action = j.getString("action");

            CommandResult result;
            if (action == "cancel") {
                result = usecase.cancelReplication(tenantId, id);
            } else {
                writeError(res, 400, "Unknown action. Use: cancel");
                return;
            }

            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Replication updated"), 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ReplicationId(extractIdFromPath(path));
            auto result = usecase.deleteReplication(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("message", "Replication deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
