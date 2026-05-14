/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.dev_space_type;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class DevSpaceTypeController : PlatformController {
    private ManageDevSpaceTypesUseCase usecase;

    this(ManageDevSpaceTypesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/dev-space-types", &handleList);
        router.get("/api/v1/application-studio/dev-space-types/*", &handleGet);
        router.post("/api/v1/application-studio/dev-space-types", &handleCreate);
        router.put("/api/v1/application-studio/dev-space-types/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/dev-space-types/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listDevSpaceTypes(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
                .set("message", "Dev space types retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DevSpaceTypeId(extractIdFromPath(path));
            auto e = usecase.getDevSpaceType(tenantId, id);
            if (e.devSpaceTypeId.isEmpty) { writeError(res, 404, "Dev space type not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DevSpaceTypeDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.predefinedExtensions = j.getString("predefinedExtensions");
            dto.supportedProjectTypes = j.getString("supportedProjectTypes");
            dto.runtimeStack = j.getString("runtimeStack");
            dto.iconUrl = j.getString("iconUrl");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Dev space type created");

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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DevSpaceTypeDTO dto;
            dto.tenantId = tenantId;
            dto.devSpaceTypeId = DevSpaceTypeId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.predefinedExtensions = j.getString("predefinedExtensions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDevSpaceType(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Dev space type updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DevSpaceTypeId(extractIdFromPath(path));
            auto result = usecase.deleteDevSpaceType(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Dev space type deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
