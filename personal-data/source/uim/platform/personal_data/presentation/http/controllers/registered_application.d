/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.registered_application;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class RegisteredApplicationController : SAPController {
    private ManageRegisteredApplicationsUseCase uc;

    this(ManageRegisteredApplicationsUseCase uc) {
        this.uc = uc;
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateRegisteredApplicationRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.endpointUrl = jsonStr(j, "endpointUrl");
            r.apiVersion = jsonStr(j, "apiVersion");
            r.contactEmail = jsonStr(j, "contactEmail");
            r.contactName = jsonStr(j, "contactName");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Application registered");
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto apps = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref a; apps) {
                jarr ~= appToJson(a);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) apps.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            if (path.length > 9 && path[$ - 9 .. $] == "/activate") return;
            if (path.length > 8 && path[$ - 8 .. $] == "/suspend") return;

            auto id = extractIdFromPath(path);
            auto a = uc.get_(id);
            if (a.id.length == 0) {
                writeError(res, 404, "Application not found");
                return;
            }
            res.writeJsonBody(appToJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateRegisteredApplicationRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.endpointUrl = jsonStr(j, "endpointUrl");
            r.apiVersion = jsonStr(j, "apiVersion");
            r.contactEmail = jsonStr(j, "contactEmail");
            r.contactName = jsonStr(j, "contactName");
            r.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Application updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);

            auto result = uc.activate(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Application activated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/suspend"
            auto id = extractIdFromPath(stripped);

            auto result = uc.suspend(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Application suspended");
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
                resp["message"] = Json("Application deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json appToJson(ref RegisteredApplication a) {
        auto j = Json.emptyObject;
        j["id"] = Json(a.id);
        j["name"] = Json(a.name);
        j["description"] = Json(a.description);
        j["status"] = Json(a.status.to!string);
        j["endpointUrl"] = Json(a.endpointUrl);
        j["apiVersion"] = Json(a.apiVersion);
        j["contactEmail"] = Json(a.contactEmail);
        j["contactName"] = Json(a.contactName);
        j["createdBy"] = Json(a.createdBy);
        j["createdAt"] = Json(a.createdAt);
        return j;
    }
}
