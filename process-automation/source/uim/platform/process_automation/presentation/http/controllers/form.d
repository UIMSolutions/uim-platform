/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.form;

// import uim.platform.process_automation.application.usecases.manage.forms;
// import uim.platform.process_automation.application.dto;
// import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class FormController : PlatformController {
    private ManageFormsUseCase uc;

    this(ManageFormsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/process-automation/forms", &handleList);
        router.get("/api/v1/process-automation/forms/*", &handleGet);
        router.post("/api/v1/process-automation/forms", &handleCreate);
        router.put("/api/v1/process-automation/forms/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/forms/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateFormRequest r;
            r.tenantId = req.getTenantId;
            r.projectId = j.getString("projectId");
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.version_ = j.getString("version");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Form created");
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
            auto forms = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (f; forms) {
                jarr ~= Json.emptyObject
                .set("id", f.id)
                .set("name", f.name)
                .set("description", f.description)
                .set("status", f.status.to!string)
                .set("version", f.version_)
                .set("createdAt", f.createdAt);
                .set("modifiedAt", f.modifiedAt);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(forms.length);
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
            auto f = uc.get_(id);
            if (f.id.isEmpty) {
                writeError(res, 404, "Form not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(f.id);
            resp["name"] = Json(f.name);
            resp["description"] = Json(f.description);
            resp["status"] = Json(f.status.to!string);
            resp["version"] = Json(f.version_);
            resp["projectId"] = Json(f.projectId);
            resp["createdBy"] = Json(f.createdBy);
            resp["modifiedBy"] = Json(f.modifiedBy);
            resp["createdAt"] = Json(f.createdAt);
            resp["modifiedAt"] = Json(f.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateFormRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.version_ = j.getString("version");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Form updated");
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Form deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
