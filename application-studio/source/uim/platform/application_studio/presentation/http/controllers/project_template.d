/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.project_template;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ProjectTemplateController : ManageHttpController {
    private ManageProjectTemplatesUseCase usecase;

    this(ManageProjectTemplatesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/project-templates", &handleList);
        router.get("/api/v1/application-studio/project-templates/*", &handleGet);
        router.post("/api/v1/application-studio/project-templates", &handleCreate);
        router.put("/api/v1/application-studio/project-templates/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/project-templates/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listProjectTemplates(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Project template list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ProjectTemplateId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project template ID", 400);

        auto temp = usecase.getProjectTemplate(tenantId, id);
        if (temp.isNull)
            return errorResponse("Project template not found", 404);

        auto responseData = temp.toJson();
        return successResponse("Project template retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ProjectTemplateDTO dto;
        dto.projectTemplateId = ProjectTemplateId(precheck.id);
        dto.tenantId = precheck.tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.requiredExtensions = data.getString(
            "requiredExtensions");
        dto.scaffoldConfig = data.getString("scaffoldConfig");
        dto.defaultFiles = data.getString("defaultFiles");
        dto.iconUrl = data.getString(
            "iconUrl");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createProjectTemplate(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Project template created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ProjectTemplateId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project template ID", 400);

        auto data = precheck.data;
        ProjectTemplateDTO dto;
        dto.tenantId = precheck.tenantId;
        dto.projectTemplateId = id;
        dto.name = data.getString(
            "name");
        dto.description = data.getString("description");
        dto.version_ = data.getString(
            "version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateProjectTemplate(dto);
        if (result.hasError)
            return errorResponse(
                result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Project template updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ProjectTemplateId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project template ID", 400);

        auto result = usecase.deleteProjectTemplate(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Project template deleted successfully", "Deleted", 200, responseData);
    }
}
