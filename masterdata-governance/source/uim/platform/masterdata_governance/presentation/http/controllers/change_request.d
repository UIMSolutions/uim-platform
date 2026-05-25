/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.change_request;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class ChangeRequestController : PlatformController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listChangeRequests(tenantId);
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
            auto id = ChangeRequestId(extractIdFromPath(path));
            auto cr = usecase.getChangeRequest(tenantId, id);
            if (cr.isNull) { writeError(res, 404, "Change request not found"); return; }
            res.writeJsonBody(cr.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ChangeRequestDTO dto;
            dto.changeRequestId = ChangeRequestId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.businessPartnerId = BusinessPartnerId(j.getString("businessPartnerId"));
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.changedFields = j.getString("changedFields");
            dto.proposedValues = j.getString("proposedValues");
            dto.currentValues = j.getString("currentValues");
            dto.comments = j.getString("comments");
            dto.dueDate = j.getString("dueDate");
            dto.externalReference = j.getString("externalReference");
            dto.requestedBy = UserId(j.getString("requestedBy"));

            auto result = usecase.createChangeRequest(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Change request created"), 201);
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
            auto id = ChangeRequestId(extractIdFromPath(path));
            auto action = j.getString("action");
            auto userId = UserId(j.getString("userId"));
            auto comments = j.getString("comments");

            CommandResult result;
            if (action == "submit") {
                result = usecase.submitChangeRequest(tenantId, id, userId);
            } else if (action == "approve") {
                result = usecase.approveChangeRequest(tenantId, id, userId, comments);
            } else if (action == "reject") {
                result = usecase.rejectChangeRequest(tenantId, id, userId, comments);
            } else if (action == "requestRevision") {
                result = usecase.requestRevision(tenantId, id, userId, comments);
            } else if (action == "withdraw") {
                result = usecase.withdrawChangeRequest(tenantId, id);
            } else {
                writeError(res, 400, "Unknown action. Use: submit, approve, reject, requestRevision, withdraw");
                return;
            }

            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Change request updated"), 200);
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
            auto id = ChangeRequestId(extractIdFromPath(path));
            auto result = usecase.deleteChangeRequest(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("message", "Change request deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
