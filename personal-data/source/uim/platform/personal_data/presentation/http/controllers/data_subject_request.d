/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject_request;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectRequestController : PlatformController {
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateDataSubjectRequestRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.requestType = j.getString("requestType");
            r.priority = j.getString("priority");
            r.description = j.getString("description");
            r.assignedTo = j.getString("assignedTo");
            r.dueDate = j.getString("dueDate");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject request created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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

            auto jarr = requests.map!(r => toJson(r)).array;

            auto resp = Json.emptyObject
                .set("count", requests.length)
                .set("resources", jarr)
                .set("message", "Data subject request list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto r = usecase.getDataSubjectRequest(id);
            if (r.isNull) {
                writeError(res, 404, "Data subject request not found");
                return;
            }
            res.writeJsonBody(requestToJson(r), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            UpdateDataSubjectRequestRequest r;
            r.tenantId = tenantId;
            r.dataSubjectRequestId = DataSubjectRequestId(extractIdFromPath(req.requestURI.to!string));
            r.status = j.getString("status");
            r.priority = j.getString("priority");
            r.assignedTo = j.getString("assignedTo");
            r.dueDate = j.getString("dueDate");
            r.comment = j.getString("comment");
            r.rejectionReason = j.getString("rejectionReason");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject request updated");

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
            auto tenantId = req.getTenantId;
            auto id = DataSubjectRequestId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteDataSubjectRequest(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject request deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
