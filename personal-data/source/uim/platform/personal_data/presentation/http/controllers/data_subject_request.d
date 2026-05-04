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
    private ManageDataSubjectRequestsUseCase uc;

    this(ManageDataSubjectRequestsUseCase uc) {
        this.uc = uc;
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
            auto j = req.json;
            CreateDataSubjectRequestRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.requestType = j.getString("requestType");
            r.priority = j.getString("priority");
            r.description = j.getString("description");
            r.assignedTo = j.getString("assignedTo");
            r.dueDate = j.getString("dueDate");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(r);
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
            TenantId tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");
            auto statusFilter = params.get("status", "");

            DataSubjectRequest[] requests;
            if (dataSubjectId.length > 0) {
                requests = uc.listByDataSubject(dataSubjectId);
            } else if (statusFilter.length > 0) {
                import std.conv : to;

                try {
                    auto s = statusFilter.to!RequestStatus;
                    requests = uc.listByStatus(s);
                } catch (Exception) {
                    requests = uc.list(tenantId);
                }
            } else {
                requests = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (r; requests) {
                jarr ~= requestToJson(r);
            }

            auto resp = Json.emptyObject
                .set("count", requests.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto r = uc.getById(id);
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
            import std.conv : to;

            auto j = req.json;
            UpdateDataSubjectRequestRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.status = j.getString("status");
            r.priority = j.getString("priority");
            r.assignedTo = j.getString("assignedTo");
            r.dueDate = j.getString("dueDate");
            r.comment = j.getString("comment");
            r.rejectionReason = j.getString("rejectionReason");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(r);
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
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.removeById(id);
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

    private Json requestToJson(DataSubjectRequest r) {
        return Json.emptyObject
            .set("id", r.id)
            .set("dataSubjectId", r.dataSubjectId)
            .set("requestType", r.requestType.to!string)
            .set("status", r.status.to!string)
            .set("priority", r.priority.to!string)
            .set("description", r.description)
            .set("assignedTo", r.assignedTo)
            .set("dueDate", r.dueDate)
            .set("rejectionReason", r.rejectionReason)
            .set("createdBy", r.createdBy)
            .set("createdAt", r.createdAt)
            .set("updatedAt", r.updatedAt);
    }
}
