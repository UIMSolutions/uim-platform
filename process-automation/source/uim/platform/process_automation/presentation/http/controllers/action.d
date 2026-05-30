/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.action;
// import uim.platform.process_automation.application.usecases.manage.actions;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class ActionController : ManageController {
    private ManageActionsUseCase actionUsecase;

    this(ManageActionsUseCase actionUsecase) {
        this.actionUsecase = actionUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/actions", &handleList);
        router.get("/api/v1/process-automation/actions/*", &handleGet);
        router.post("/api/v1/process-automation/actions", &handleCreate);
        router.put("/api/v1/process-automation/actions/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/actions/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;

            auto data = precheck.data;
            CreateActionRequest r;
            r.tenantId = tenantId;
            r.projectId = ProjectId(data.getString("projectId"));
            r.actionId = ActionId(precheck.id);
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.type = data.getString("type");
            r.method = data.getString("method");
            r.baseUrl = data.getString("baseUrl");
            r.path = data.getString("path");
            r.authType = data.getString("authType");
            r.destinationName = data.getString("destinationName");
            r.version_ = data.getString("version");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = actionUsecase.createAction(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action created");

                res.writeJsonBody(resp, 201);
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

            auto actions = actionUsecase.listActions(tenantId);

            auto jarr = Json.emptyArray;
            foreach (a; actions) {
                jarr ~= Json.emptyObject
                    .set("id", a.id)
                    .set("name", a.name)
                    .set("description", a.description)
                    .set("status", a.status.to!string)
                    .set("type", a.type.to!string)
                    .set("baseUrl", a.baseUrl)
                    .set("version", a.version_)
                    .set("createdAt", a.createdAt)
                    .set("updatedAt", a.updatedAt);
            }

            auto resp = Json.emptyObject
                .set("count", actions.length)
                .set("resources", list);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = precheck.tenantId;
            auto id = ActionId(precheck.id);

            auto a = actionUsecase.getAction(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Action not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("status", a.status.to!string)
                .set("type", a.type.to!string)
                .set("baseUrl", a.baseUrl)
                .set("path", a.path)
                .set("authType", a.authType)
                .set("destinationName", a.destinationName)
                .set("version", a.version_)
                .set("projectId", a.projectId)
                .set("createdBy", a.createdBy)
                .set("updatedBy", a.updatedBy)
                .set("createdAt", a.createdAt)
                .set("updatedAt", a.updatedAt);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            UpdateActionRequest r;
            r.tenantId = tenantId;
            r.actionId = ActionId(precheck.id);
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.baseUrl = data.getString("baseUrl");
            r.path = data.getString("path");
            r.authType = data.getString("authType");
            r.destinationName = data.getString("destinationName");
            r.version_ = data.getString("version");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = actionUsecase.updateAction(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
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

            auto id = ActionId(precheck.id);
            auto result = actionUsecase.deleteAction(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
