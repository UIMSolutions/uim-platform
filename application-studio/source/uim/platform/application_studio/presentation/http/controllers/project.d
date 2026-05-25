/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.project;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ProjectController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listProjects(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResoponse("Project list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = ProjectId(extractIdFromPath(path));
        if (id.isNull)
            return errorResponse("Invalid project ID", "BadRequest", 400);

        auto e = usecase.getProject(tenantId, id);
        if (e.isNull)
            return errorResponse("Project not found", "NotFound", 404);

        return successResponse("Project retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = recheck.data;

        ProjectDTO dto;
        dto.projectId = ProjectId(data.getString("id"));
        dto.tenantId = tenantId;
        dto.devSpaceId = data.getString("devSpaceId");
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.templateId = data.getString("templateId");
        dto.rootPath = data.getString("rootPath");
        dto.gitRepositoryUrl = data.getString("gitRepositoryUrl");
        dto.gitBranch = data.getString("gitBranch");
        dto.namespace_ = data.getString("namespace");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createProject(dto);
        if (result.hasError)
            return errorResponse(result.message, "BadRequest", 400);

        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Project created successfully", "Created", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto path = req.requestURI.to!string;

        ProjectDTO dto;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.gitRepositoryUrl = data.getString("gitRepositoryUrl");
        dto.gitBranch = data.getString("gitBranch");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateProject(tenantId, dto);
        if (result.hasError)
            return errorResponse(result.message, "BadRequest", 400);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Project updated");

        res.writeJsonBody(resp, 200);
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
