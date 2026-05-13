/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.project_member;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ProjectMemberController : PlatformController {
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

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();  

            auto items = usecase.listProjectMembers(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Project members retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ProjectMemberId(extractIdFromPath(path));

            auto e = usecase.getProjectMember(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Project member not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;

            ProjectMemberDTO dto;
            dto.projectMemberId = ProjectMemberId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.applicationId = ApplicationId(j.getString("applicationId"));
            dto.userId = UserId(j.getString("userId"));
            dto.displayName = j.getString("displayName");
            dto.email = j.getString("email");
            dto.role = j.getString("role");
            dto.permissions = j.getString("permissions");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createProjectMember(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Project member added");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;
            
            ProjectMemberDTO dto;
            dto.tenantId = tenantId;
            dto.projectMemberId = ProjectMemberId(extractIdFromPath(path));
            dto.displayName = j.getString("displayName");
            dto.email = j.getString("email");
            dto.permissions = j.getString("permissions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateProjectMember(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Project member updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ProjectMemberId(extractIdFromPath(path));

            auto result = usecase.deleteProjectMember(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Project member deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
