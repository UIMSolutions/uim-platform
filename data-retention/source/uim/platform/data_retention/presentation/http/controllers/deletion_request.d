module uim.platform.data_retention.presentation.http.controllers.deletion_request;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DeletionRequestController : ManageController {
    private ManageDeletionRequestsUseCase usecase;

    this(ManageDeletionRequestsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/deletion-requests", &handleCreate);
        router.get("/api/v1/data-retention/deletion-requests", &handleList);
        router.get("/api/v1/data-retention/deletion-requests/*", &handleGet);
        router.put("/api/v1/data-retention/deletion-requests/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/deletion-requests/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDeletionRequestRequest r;
        r.tenantId = tenantId;
        r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
        r.applicationGroupId = ApplicationGroupId(data.getString("applicationGroupId"));
        r.actionType = data.getString("actionType").to!ActionType;
        r.reason = data.getString("reason");
        r.requestedBy = data.getString("requestedBy");

        auto result = usecase.createDeletionRequest(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
    } else {
        writeError(res, 400, result.message);
    }
} catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}

override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listDeletionRequests(tenantId);
    auto jarr = Json.emptyArray;
    foreach (dr; items) {
        jarr ~= Json.emptyObject
            .set("id", dr.id.value)
            .set("dataSubjectId", dr.dataSubjectId.value)
            .set("applicationGroupId", dr.applicationGroupId.value)
            .set("actionType", dr.actionType.to!string)
            .set("status", dr.status.to!string);
    }
    res.writeJsonBody(Json.emptyObject.set("items", jarr)
            .set("totalCount", items.length), 200);
}
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}

override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto tenantId = precheck.tenantId;
        auto id = DeletionRequestId(precheck.id);
        auto dr = usecase.getDeletionRequest(tenantId, id);
        if (dr.isNull) {
            writeError(res, 404, "Deletion request not found");
            return;
        }

        auto response = Json.emptyObject
            .set("id", dr.id.value)
            .set("dataSubjectId", dr.dataSubjectId.value)
            .set("applicationGroupId", dr.applicationGroupId.value)
            .set("actionType", dr.actionType.to!string)
            .set("status", dr.status.to!string)
            .set("reason", dr.reason)
            .set("requestedBy", dr.requestedBy)
            .set("requestedAt", dr.requestedAt);

        res.writeJsonBody(response, 200);
    } catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeletionRequestId(precheck.id);
    auto data = precheck.data;
    UpdateDeletionRequestRequest r;
    r.tenantId = tenantId;
    r.deletionRequestId = id;
    r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.status = data.getString("status");
    r.errorMessage = data.getString("errorMessage");

    auto result = usecase.updateDeletionRequest(r);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto response = Json.emptyObject
        .set("id", result.id.value)
        .set("dataSubjectId", r.dataSubjectId.value)
        .set("status", r.status)
        .set("errorMessage", r.errorMessage);

    return successResponse(response, 200);
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeletionRequestId(precheck.id);
    auto data = precheck.data;
    UpdateDeletionRequestRequest r;
    r.tenantId = tenantId;
    r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.status = data.getString("status");
    r.errorMessage = data.getString("errorMessage");

    auto result = usecase.updateDeletionRequest(id, r);
    if (result.hasError)
        return errorResponse(result.message, 400);
    res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
} else {
    writeError(res, 400, result.message);
}
} catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeletionRequestId(precheck.id);

    auto result = usecase.deleteDeletionRequest(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);
    res.writeJsonBody(Json.emptyObject, 204);
} else {
    writeError(res, 404, result.message);
}
} catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}
}
