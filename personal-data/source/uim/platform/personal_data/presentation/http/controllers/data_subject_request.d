/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject_request;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectRequestController : ManageHttpController {
    private ManageDataSubjectRequestsUseCase usecase;

    this(ManageDataSubjectRequestsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/requests", &handleList);
        router.get("/api/v1/personal-data/requests/*", &handleGet);
        router.post("/api/v1/personal-data/requests", &handleCreate);
        router.put("/api/v1/personal-data/requests/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/requests/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDataSubjectRequestRequest r;
        r.tenantId = tenantId;
        r.id = precheck.id;
        r.dataSubjectId = data.getString("dataSubjectId");
        r.requestType = data.getString("requestType");
        r.priority = data.getString("priority");
        r.description = data.getString("description");
        r.assignedTo = data.getString("assignedTo");
        r.dueDate = data.getString("dueDate");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", result.id);

        return successResponse("Data subject request created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto params = req.queryParams();
        auto dataSubjectId = params.get("dataSubjectId", "");
        auto statusFilter = params.get("status", "");

        DataSubjectRequest[] requests;
        if (!dataSubjectId.isEmpty) {
            requests = usecase.listDataSubjectRequests(dataSubjectId);
        } else if (!statusFilter.isEmpty) {
            try {
                auto s = statusFilter.to!RequestStatus;
                requests = usecase.listDataSubjectRequests(s);
            } catch (Exception) {
                requests = usecase.listDataSubjectRequests(tenantId);
            }
        } else {
            requests = usecase.listDataSubjectRequests(tenantId);
        }

        auto jarr = requests.map!(r => toJson(r)).array.toJson;

        auto resp = Json.emptyObject
            .set("count", requests.length)
            .set("resources", jarr);

        return successResponse("Data subject requests retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DataSubjectRequestId(precheck.id);
        auto r = usecase.getDataSubjectRequest(id);
        if (r.isNull)
            return errorResponse("Data subject request not found", 404);
        return successResponse("Data subject request retrieved successfully", "Retrieved", 200, r
                .toJson);

    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        UpdateDataSubjectRequestRequest r;
        r.tenantId = tenantId;
        r.dataSubjectRequestId = DataSubjectRequestId(precheck.id);
        r.status = data.getString("status");
        r.priority = data.getString("priority");
        r.assignedTo = data.getString("assignedTo");
        r.dueDate = data.getString("dueDate");
        r.comment = data.getString("comment");
        r.rejectionReason = data.getString("rejectionReason");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.update(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);
        return successResponse("Data subject request updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectRequestId(precheck.id);
        auto result = usecase.deleteDataSubjectRequest(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);
        return successResponse("Data subject request deleted successfully", "Deleted", 200, resp);
    }
}
