/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject_request;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectRequestController : SAPController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.dataSubjectId = jsonStr(j, "dataSubjectId");
            r.requestType = jsonStr(j, "requestType");
            r.priority = jsonStr(j, "priority");
            r.description = jsonStr(j, "description");
            r.assignedTo = jsonStr(j, "assignedTo");
            r.dueDate = jsonStr(j, "dueDate");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject request created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
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
            } ) {
                requests = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (ref r; requests) {
                jarr ~= requestToJson(r);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) requests.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto r = uc.get_(id);
            if (r.id.length == 0) {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.status = jsonStr(j, "status");
            r.priority = jsonStr(j, "priority");
            r.assignedTo = jsonStr(j, "assignedTo");
            r.dueDate = jsonStr(j, "dueDate");
            r.comment = jsonStr(j, "comment");
            r.rejectionReason = jsonStr(j, "rejectionReason");
            r.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject request updated");
                res.writeJsonBody(resp, 200);
            } ) {
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject request deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json requestToJson(ref DataSubjectRequest r) {
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["dataSubjectId"] = Json(r.dataSubjectId);
        j["requestType"] = Json(r.requestType.to!string);
        j["status"] = Json(r.status.to!string);
        j["priority"] = Json(r.priority.to!string);
        j["description"] = Json(r.description);
        j["assignedTo"] = Json(r.assignedTo);
        j["dueDate"] = Json(r.dueDate);
        j["rejectionReason"] = Json(r.rejectionReason);
        j["createdBy"] = Json(r.createdBy);
        j["createdAt"] = Json(r.createdAt);
        j["modifiedAt"] = Json(r.modifiedAt);
        return j;
    }
}
