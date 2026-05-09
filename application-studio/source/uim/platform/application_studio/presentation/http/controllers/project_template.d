/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.project_template;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ProjectTemplateController : PlatformController {
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listProjectTemplates(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Project template list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ProjectTemplateId(extractIdFromPath(path));

            auto e = usecase.getProjectTemplate(tenantId, id);
            if (e.id.isEmpty) {
                writeError(res, 404, "Project template not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ProjectTemplateDTO dto;
            dto.projectTemplateId = ProjectTemplateId(j.getString("id"));
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.requiredExtensions = j.getString("requiredExtensions");
            dto.scaffoldConfig = j.getString("scaffoldConfig");
            dto.defaultFiles = j.getString("defaultFiles");
            dto.iconUrl = j.getString("iconUrl");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto tenantId = req.getTenantId;
            auto result = usecase.createProjectTemplate(tenantId, dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Project template created");

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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            ProjectTemplateDTO dto;
            dto.projectTemplateId = ProjectTemplateId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateProjectTemplate(tenantId, dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Project template updated");

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
            

            auto path = req.requestURI.to!string;
            auto id = ProjectTemplateId(extractIdFromPath(path));
            auto tenantId = req.getTenantId;
            auto result = usecase.removeProjectTemplate(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Project template deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
