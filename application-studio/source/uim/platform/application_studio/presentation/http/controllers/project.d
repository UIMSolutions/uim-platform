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
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Project list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ProjectDTO dto;
        dto.projectId = ProjectId(precheck.id);
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
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Project created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ProjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project ID", 400);

        auto e = usecase.getProject(tenantId, id);
        if (e.isNull)
            return errorResponse("Project not found", 404);

        return successResponse("Project retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ProjectDTO dto;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.gitRepositoryUrl = data.getString("gitRepositoryUrl");
        dto.gitBranch = data.getString("gitBranch");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateProject(tenantId, dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Project updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ProjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project ID", 400);

        auto result = usecase.deleteProject(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto resp = Json.emptyObject
            .set("id", id);

        return successResponse("Project deleted successfully", "Deleted", 200, resp);
    }
}
