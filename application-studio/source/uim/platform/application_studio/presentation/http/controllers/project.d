/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.project;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ProjectController : PlatformController {
    private ManageProjectsUseCase usecase;

    this(ManageProjectsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/projects", &handleList);
        router.get("/api/v1/application-studio/projects/*", &handleGet);
        router.post("/api/v1/application-studio/projects", &handleCreate);
        router.put("/api/v1/application-studio/projects/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/projects/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listProjects(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Project list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ProjectId(extractIdFromPath(path));
            auto e = usecase.getProject(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Project not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ProjectDTO dto;
            dto.projectId = ProjectId(j.getString("id"));
            dto.tenantId = req.getTenantId;
            dto.devSpaceId = j.getString("devSpaceId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.templateId = j.getString("templateId");
            dto.rootPath = j.getString("rootPath");
            dto.gitRepositoryUrl = j.getString("gitRepositoryUrl");
            dto.gitBranch = j.getString("gitBranch");
            dto.namespace_ = j.getString("namespace");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createProject(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Project created");

                res.writeJsonBody(resp, 201);
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

            ProjectDTO dto;
            dto.projectId = ProjectId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.gitRepositoryUrl = j.getString("gitRepositoryUrl");
            dto.gitBranch = j.getString("gitBranch");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateProject(tenantId, dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Project updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            auto id = ProjectId(extractIdFromPath(path));
            auto result = usecase.deleteProject(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Project deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
