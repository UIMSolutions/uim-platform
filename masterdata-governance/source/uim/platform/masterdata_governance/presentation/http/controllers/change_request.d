/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.change_request;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class ChangeRequestController : ManageController {
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = ChangeRequestId(precheck.id);
            auto cr = usecase.getChangeRequest(tenantId, id);
            if (cr.isNull) { writeError(res, 404, "Change request not found"); return; }
            res.writeJsonBody(cr.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            ChangeRequestDTO dto;
            dto.changeRequestId = ChangeRequestId(precheck.id);
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            auto id = ChangeRequestId(precheck.id);
            auto action = data.getString("action");
            auto userId = UserId(data.getString("userId"));
            auto comments = data.getString("comments");

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

            if (result.hasError)
            return errorResponse(result.message, 400);
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = ChangeRequestId(precheck.id);
            auto result = usecase.deleteChangeRequest(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("message", "Change request deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
