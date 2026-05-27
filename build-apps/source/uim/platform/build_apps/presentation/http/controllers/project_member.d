/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.project_member;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ProjectMemberController : ManageController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();  

            auto items = usecase.listProjectMembers(tenantId);
            auto list = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Project members retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = ProjectMemberId(precheck.id);

            auto e = usecase.getProjectMember(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Project member not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto data = precheck.data;
            ProjectMemberDTO dto;
            dto.projectMemberId = ProjectMemberId(precheck.id);
            dto.tenantId = tenantId;
            dto.applicationId = ApplicationId(data.getString("applicationId"));
            dto.userId = UserId(data.getString("userId"));
            dto.displayName = data.getString("displayName");
            dto.email = data.getString("email");
            dto.role = data.getString("role");
            dto.permissions = data.getString("permissions");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createProjectMember(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Project member added");

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
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            
            ProjectMemberDTO dto;
            dto.tenantId = tenantId;
            dto.projectMemberId = ProjectMemberId(precheck.id);
            dto.displayName = data.getString("displayName");
            dto.email = data.getString("email");
            dto.permissions = data.getString("permissions");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateProjectMember(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Project member updated");

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
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ProjectMemberId(precheck.id);

            auto result = usecase.deleteProjectMember(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Project member deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
