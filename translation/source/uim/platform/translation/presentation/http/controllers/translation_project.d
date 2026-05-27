/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.translation_project;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// CRUD /api/v1/translation/projects — manage software translation projects.
class TranslationProjectController : ManageController {
    private ManageTranslationProjectsUseCase usecase;

    this(ManageTranslationProjectsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/translation/projects", &handleList);
        router.get("/api/v1/translation/projects/*", &handleGet);
        router.post("/api/v1/translation/projects", &handleCreate);
        router.put("/api/v1/translation/projects/*", &handleUpdate);
        router.delete_("/api/v1/translation/projects/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;

            CreateTranslationProjectRequest r;
            r.tenantId = tenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.projectType = j.getString("projectType");
            r.sourceLanguage = j.getString("sourceLanguage");
            r.provider = j.getString("provider");
            r.repositoryUrl = j.getString("repositoryUrl");
            r.baseBranch = j.getString("baseBranch");
            r.abapSystemId = j.getString("abapSystemId");

            if (j["targetLanguages"].type == Json.Type.array)
                foreach (l; j["targetLanguages"])
                    r.targetLanguages ~= l.get!string;

            auto result = usecase.createProject(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(
                    Json.emptyObject.set("id", result.id).set("message", "Translation project created"),
                    201
                );
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

            auto projects = usecase.listProjects(tenantId);

            auto arr = Json.emptyArray;
            foreach (p; projects) {
                auto langs = Json.emptyArray;
                foreach (l; p.targetLanguages) langs ~= Json(l);

                arr ~= Json.emptyObject
                    .set("id", p.id.value)
                    .set("name", p.name)
                    .set("description", p.description)
                    .set("projectType", p.projectType.to!string)
                    .set("sourceLanguage", p.sourceLanguage)
                    .set("targetLanguages", langs)
                    .set("status", p.status.to!string)
                    .set("provider", p.provider.to!string)
                    .set("createdAt", p.createdAt)
                    .set("updatedAt", p.updatedAt);
            }

            res.writeJsonBody(
                Json.emptyObject.set("count", projects.length).set("projects", arr),
                200
            );
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TranslationProjectprecheck.id);
            auto p = usecase.getProject(tenantId, id);
            if (p.isNull) {
                writeError(res, 404, "Translation project not found");
                return;
            }
            res.writeJsonBody(p.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;

            UpdateTranslationProjectRequest r;
            r.tenantId = tenantId;
            r.projectId = TranslationProjectprecheck.id);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.provider = j.getString("provider");
            r.repositoryUrl = j.getString("repositoryUrl");
            r.baseBranch = j.getString("baseBranch");
            r.status = j.getString("status");

            if (j["targetLanguages"].type == Json.Type.array)
                foreach (l; j["targetLanguages"])
                    r.targetLanguages ~= l.get!string;

            auto result = usecase.updateProject(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(
                    Json.emptyObject.set("id", result.id).set("message", "Translation project updated"),
                    200
                );
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TranslationProjectprecheck.id);
            auto result = usecase.deleteProject(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
