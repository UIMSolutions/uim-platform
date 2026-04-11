/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.artifact;

import uim.platform.process_automation.application.usecases.manage.artifacts;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

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
            r.tags = jsonStrArray(j, "tags");
            r.contentUrl = j.getString("contentUrl");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Artifact published");
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
            auto artifacts = uc.list();

            auto jarr = Json.emptyArray;
            foreach (a; artifacts) {
                auto aj = Json.emptyObject;
                aj["id"] = Json(a.id);
                aj["name"] = Json(a.name);
                aj["description"] = Json(a.description);
                aj["type"] = Json(a.type.to!string);
                aj["status"] = Json(a.status.to!string);
                aj["version"] = Json(a.version_);
                aj["author"] = Json(a.author);
                aj["category"] = Json(a.category);
                aj["downloadCount"] = Json(a.downloadCount);
                aj["rating"] = Json(a.rating);
                jarr ~= aj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) artifacts.length);
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
            auto a = uc.get_(id);
            if (a.id.isEmpty) {
                writeError(res, 404, "Artifact not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(a.id);
            resp["name"] = Json(a.name);
            resp["description"] = Json(a.description);
            resp["type"] = Json(a.type.to!string);
            resp["status"] = Json(a.status.to!string);
            resp["version"] = Json(a.version_);
            resp["author"] = Json(a.author);
            resp["category"] = Json(a.category);
            resp["tags"] = stringsToJsonArray(a.tags);
            resp["contentUrl"] = Json(a.contentUrl);
            resp["downloadCount"] = Json(a.downloadCount);
            resp["rating"] = Json(a.rating);
            resp["publishedAt"] = Json(a.publishedAt);
            resp["updatedAt"] = Json(a.updatedAt);
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
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Artifact updated");
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
                resp["message"] = Json("Artifact deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
