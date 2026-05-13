/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.repository_;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class RepositoryController : PlatformController {
    private ManageRepositoriesUseCase usecase;

    this(ManageRepositoriesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/dms-integration/repositories", &handleList);
        router.get("/api/v1/dms-integration/repositories/*", &handleGet);
        router.post("/api/v1/dms-integration/repositories", &handleCreate);
        router.put("/api/v1/dms-integration/repositories/*", &handleUpdate);
        router.delete_("/api/v1/dms-integration/repositories/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listRepositories(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = RepositoryId(extractIdFromPath(path));
            auto item = usecase.getRepository(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Repository not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            RepositoryDTO dto;
            dto.repositoryId = RepositoryId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.repositoryType = j.getString("repositoryType");
            dto.externalUrl = j.getString("externalUrl");
            dto.cmisVersion = j.getString("cmisVersion");
            dto.encryptionEnabled = j.getBool("encryptionEnabled");
            dto.capacityLimitBytes = j.getLong("capacityLimitBytes");
            dto.repositoryKey = j.getString("repositoryKey");
            dto.externalRepositoryId = j.getString("externalRepositoryId");
            dto.region = j.getString("region");
            dto.isDefault = j.getBool("isDefault");
            dto.isReadOnly = j.getBool("isReadOnly");
            dto.versioningEnabled = j.getBool("versioningEnabled");
            dto.fullTextSearchEnabled = j.getBool("fullTextSearchEnabled");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.createRepository(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Repository created"), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            auto action = j.getString("action");
            auto id = RepositoryId(extractIdFromPath(path));

            if (action == "activate") {
                auto result = usecase.activateRepository(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Repository activated"), 200);
                else writeError(res, 400, result.error);
                return;
            }
            if (action == "deactivate") {
                auto result = usecase.deactivateRepository(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Repository deactivated"), 200);
                else writeError(res, 400, result.error);
                return;
            }

            RepositoryDTO dto;
            dto.repositoryId = id;
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.externalUrl = j.getString("externalUrl");
            dto.region = j.getString("region");
            dto.isDefault = j.getBool("isDefault");
            dto.isReadOnly = j.getBool("isReadOnly");
            dto.versioningEnabled = j.getBool("versioningEnabled");
            dto.fullTextSearchEnabled = j.getBool("fullTextSearchEnabled");
            dto.updatedBy = UserId(j.getString("updatedBy"));
            auto result = usecase.updateRepository(dto);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Repository updated"), 200);
            else writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = RepositoryId(extractIdFromPath(path));
            auto result = usecase.deleteRepository(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Repository deleted"), 200);
            else writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
