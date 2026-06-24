/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.change_request;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class ChangeRequestController : ManageHttpController {
    private ManageChangeRequestsUseCase usecase;

    this(ManageChangeRequestsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/masterdata-governance/change-requests", &handleList);
        router.get("/api/v1/masterdata-governance/change-requests/*", &handleGet);
        router.post("/api/v1/masterdata-governance/change-requests", &handleCreate);
        router.put("/api/v1/masterdata-governance/change-requests/*", &handleUpdate);
        router.delete_("/api/v1/masterdata-governance/change-requests/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listChangeRequests(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Change request list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ChangeRequestId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid change request ID", 400);

        auto cr = usecase.getChangeRequest(tenantId, id);
        if (cr.isNull)
            return errorResponse("Change request not found", 404);

        auto responseData = cr.toJson();
        return successResponse("Change request retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ChangeRequestDTO dto;
        dto.tenantId = tenantId;
        dto.businessPartnerId = BusinessPartnerId(data.getString("businessPartnerId"));
        dto.subject = data.getString("subject");
        dto.description = data.getString("description");
        dto.changedFields = data.getString("changedFields");
        dto.proposedValues = data.getString("proposedValues");
        dto.currentValues = data.getString("currentValues");
        dto.comments = data.getString("comments");
        dto.dueDate = data.getString("dueDate");
        dto.externalReference = data.getString("externalReference");
        dto.requestedBy = UserId(data.getString("requestedBy"));

        auto result = usecase.createChangeRequest(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Change request created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ChangeRequestId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid change request ID", 400);

        auto data = precheck.data;
        auto userId = UserId(data.getString("userId"));
        auto comments = data.getString("comments");

        auto action = data.getString("action");
        CommandResult result;
        switch (action) {
        case "submit":
            result = usecase.submitChangeRequest(tenantId, id, userId);
            break;
        case "approve":
            result = usecase.approveChangeRequest(tenantId, id, userId, comments);
            break;
        case "reject":
            result = usecase.rejectChangeRequest(tenantId, id, userId, comments);
            break;
        case "requestRevision":
            result = usecase.requestRevision(tenantId, id, userId, comments);
            break;
        case "withdraw":
            result = usecase.withdrawChangeRequest(tenantId, id);
            break;
        default:
            return errorResponse("Unknown action. Use: submit, approve, reject, requestRevision, withdraw", 400);
        }

        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", result.id);
        return successResponse("Change request updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ChangeRequestId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid change request ID", 400);

        auto result = usecase.deleteChangeRequest(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Change request deleted successfully", "Deleted", 200, responseData);
    }
}
