/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.replication;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class ReplicationController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listReplications(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Replication list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ReplicationDTO dto;
        dto.tenantId = tenantId;
        dto.businessPartnerId = BusinessPartnerId(data.getString("businessPartnerId"));
        dto.targetSystem = data.getString("targetSystem");
        dto.targetSystemType = data.getString("targetSystemType");
        dto.replicationType = data.getString("replicationType");
        dto.scheduledAt = data.getLong("scheduledAt");
        dto.replicatedFields = data.getString("replicatedFields");
        dto.maxRetries = data.getInteger("maxRetries");
        dto.correlationId = data.getString("correlationId");
        dto.batchId = data.getString("batchId");
        dto.triggeredBy = UserId(data.getString("triggeredBy"));

        auto result = usecase.createReplication(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Replication created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ReplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid replication ID", 400);

        auto rep = usecase.getReplication(tenantId, id);
        if (rep.isNull)
            return errorResponse("Replication not found", 404);

        auto responseData = rep.toJson();
        return successResponse("Replication retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = ReplicationId(precheck.id);
        auto action = data.getString("action");

        CommandResult result;
        if (action == "cancel") {
            result = usecase.cancelReplication(tenantId, id);
        } else {
            return errorResponse("Unknown action. Use: cancel", 400);
        }
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Replication updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ReplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid replication ID", 400);

        auto result = usecase.deleteReplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Replication deleted successfully", "Deleted", 200, responseData);
    }
}
