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
    private ManageProjectMembersUseCase uc;

    this(ManageProjectMembersUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/build-apps/project-members", &handleList);
        router.get("/api/v1/build-apps/project-members/*", &handleGet);
        router.post("/api/v1/build-apps/project-members", &handleCreate);
        router.put("/api/v1/build-apps/project-members/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/project-members/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => e.toJson()).array;
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Project members retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(ProjectMemberId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Project member not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ProjectMemberDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.applicationId = j.getString("applicationId");
            dto.userId = j.getString("userId");
            dto.displayName = j.getString("displayName");
            dto.email = j.getString("email");
            dto.role = j.getString("role");
            dto.permissions = j.getString("permissions");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(dto);
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

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            ProjectMemberDTO dto;
            dto.id = extractIdFromPath(path);
            dto.displayName = j.getString("displayName");
            dto.email = j.getString("email");
            dto.permissions = j.getString("permissions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(dto);
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(ProjectMemberId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Project member removed");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
