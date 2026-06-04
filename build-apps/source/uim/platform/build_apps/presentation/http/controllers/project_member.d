/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.project_member;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ProjectMemberController : ManageHttpController {
    private ManageProjectMembersUseCase usecase;

    this(ManageProjectMembersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/project-members", &handleList);
        router.get("/api/v1/build-apps/project-members/*", &handleGet);
        router.post("/api/v1/build-apps/project-members", &handleCreate);
        router.put("/api/v1/build-apps/project-members/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/project-members/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listProjectMembers(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Project member list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ProjectMemberId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project member ID", 400);

        auto member = usecase.getProjectMember(tenantId, id);
        if (member.isNull)
            return errorResponse("Project member not found", 404);

        auto responseData = member.toJson();
        return successResponse("Project member retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ProjectMemberDTO dto;
        dto.id = precheck.id;
        dto.tenantId = tenantId;
        dto.applicationId = data.getString("applicationId");
        dto.userId = UserId(data.getString("userId"));
        dto.displayName = data.getString("displayName");
        dto.email = data.getString("email");
        dto.role = data.getString("role");
        dto.permissions = data.getString("permissions");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createProjectMember(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Project member created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ProjectMemberId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid project member ID", 400);

        auto data = precheck.data;
        ProjectMemberDTO dto;
        dto.tenantId = tenantId;
        dto.id = precheck.id;
        dto.displayName = data.getString("displayName");
        dto.email = data.getString("email");
        dto.permissions = data.getString("permissions");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateProjectMember(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Project member updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ProjectMemberId(precheck.id);

        auto result = usecase.deleteProjectMember(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("message", "Project member deleted");

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Project member deleted successfully", "Deleted", 200, responseData);
    }
}
