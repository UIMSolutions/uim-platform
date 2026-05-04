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
    private ManageDevSpaceTypesUseCase uc;

    this(ManageDevSpaceTypesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/dev-space-types", &handleList);
        router.get("/api/v1/application-studio/dev-space-types/*", &handleGet);
        router.post("/api/v1/application-studio/dev-space-types", &handleCreate);
        router.put("/api/v1/application-studio/dev-space-types/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/dev-space-types/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => e.devSpaceTypeToJson()).array;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

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
            auto e = uc.getById(DevSpaceTypeId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Dev space type not found"); return; }
            res.writeJsonBody(e.devSpaceTypeToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
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

            auto result = uc.create(dto);
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

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DevSpaceTypeDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.predefinedExtensions = j.getString("predefinedExtensions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(dto);
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(DevSpaceTypeId(id));
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
