/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.registered_application;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class RegisteredApplicationController : PlatformController {
    private ManageRegisteredApplicationsUseCase usecase;

    this(ManageRegisteredApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/personal-data/applications", &handleList);
        router.get("/api/v1/personal-data/applications/*", &handleGet);
        router.post("/api/v1/personal-data/applications", &handleCreate);
        router.put("/api/v1/personal-data/applications/*", &handleUpdate);
        router.post("/api/v1/personal-data/applications/*/activate", &handleActivate);
        router.post("/api/v1/personal-data/applications/*/suspend", &handleSuspend);
        router.delete_("/api/v1/personal-data/applications/*", &handleDelete);
    }

    protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateRegisteredApplicationRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.endpointUrl = j.getString("endpointUrl");
            r.apiVersion = j.getString("apiVersion");
            r.contactEmail = j.getString("contactEmail");
            r.contactName = j.getString("contactName");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application registered");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto apps = usecase.list(tenantId);

            auto jarr = apps.map!(a => appToJson(a)).array.toJson; {

            auto resp = Json.emptyObject
              .set("count", apps.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto path = req.requestURI.to!string;
            if (path.length > 9 && path[$ - 9 .. $] == "/activate") return;
            if (path.length > 8 && path[$ - 8 .. $] == "/suspend") return;

            auto id = extractIdFromPath(path);
            auto a = usecase.getById(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Application not found");
                return;
            }
            res.writeJsonBody(toJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto j = req.json;
            UpdateRegisteredApplicationRequest r;
            r.tenantId = tenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.endpointUrl = j.getString("endpointUrl");
            r.apiVersion = j.getString("apiVersion");
            r.contactEmail = j.getString("contactEmail");
            r.contactName = j.getString("contactName");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);

            auto result = usecase.activate(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application activated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/suspend"
            auto id = extractIdFromPath(stripped);

            auto result = usecase.suspend(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application suspended");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = usecase.deleteRegisteredApplication(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json appToJson(RegisteredApplication a) {
        return Json.emptyObject
        .set("id", a.id)
        .set("name", a.name)
        .set("description", a.description)
        .set("status", a.status.to!string)
        .set("endpointUrl", a.endpointUrl)
        .set("apiVersion", a.apiVersion)
        .set("contactEmail", a.contactEmail)
        .set("contactName", a.contactName)
        .set("createdBy", a.createdBy)
        .set("createdAt", a.createdAt);
    }
}
