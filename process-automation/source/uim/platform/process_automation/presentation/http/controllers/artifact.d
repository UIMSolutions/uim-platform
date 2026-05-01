/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.artifact;

// import uim.platform.process_automation.application.usecases.manage.artifacts;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class ArtifactController : PlatformController {
    private ManageArtifactsUseCase uc;

    this(ManageArtifactsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/store/artifacts", &handleList);
        router.get("/api/v1/process-automation/store/artifacts/*", &handleGet);
        router.post("/api/v1/process-automation/store/artifacts", &handleCreate);
        router.put("/api/v1/process-automation/store/artifacts/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/store/artifacts/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateArtifactRequest r;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.version_ = j.getString("version");
            r.author = j.getString("author");
            r.category = j.getString("category");
            r.tags = getStringArray(j, "tags");
            r.contentUrl = j.getString("contentUrl");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Artifact published");

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
            auto artifacts = uc.list();

            auto jarr = Json.emptyArray;
            foreach (a; artifacts) {
                jarr ~= Json.emptyObject
                    .set("id", a.id)
                    .set("name", a.name)
                    .set("description", a.description)
                    .set("type", a.type.to!string)
                    .set("status", a.status.to!string)
                    .set("version", a.version_)
                    .set("author", a.author)
                    .set("category", a.category)
                    .set("downloadCount", a.downloadCount)
                    .set("rating", a.rating);
            }

            auto resp = Json.emptyObject
                .set("count", artifacts.length)
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
            auto a = uc.getById(id);
            if (a.isNull) {
                writeError(res, 404, "Artifact not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("type", a.type.to!string)
                .set("status", a.status.to!string)
                .set("version", a.version_)
                .set("author", a.author)
                .set("category", a.category)
                .set("tags", a.tags)
                .set("contentUrl", a.contentUrl)
                .set("downloadCount", a.downloadCount)
                .set("rating", a.rating)
                .set("publishedAt", a.publishedAt)
                .set("updatedAt", a.updatedAt);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateArtifactRequest r;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.version_ = j.getString("version");
            r.contentUrl = j.getString("contentUrl");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Artifact updated");

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
                    .set("message", "Artifact deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
