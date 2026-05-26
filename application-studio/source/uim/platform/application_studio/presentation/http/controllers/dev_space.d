/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.dev_space;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class DevSpaceController : ManageController {
    private ManageDevSpacesUseCase usecase;

    this(ManageDevSpacesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/application-studio/dev-spaces", &handleList);
        router.get("/api/v1/application-studio/dev-spaces/*", &handleGet);
        router.post("/api/v1/application-studio/dev-spaces", &handleCreate);
        router.put("/api/v1/application-studio/dev-spaces/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/dev-spaces/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = usecase.listDevSpaces();
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Dev space list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DevSpaceId(precheck.id);
            auto e = usecase.getDevSpace(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Dev space not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DevSpaceDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.devSpaceTypeId = DevSpaceTypeId(j.getString("devSpaceTypeId"));
            dto.extensions = j.getString("extensions");
            dto.owner = UserId(j.getString("owner"));
            dto.region = j.getString("region");
            dto.hibernateAfterDays = j.getString("hibernateAfterDays");
            dto.memoryLimit = j.getString("memoryLimit");
            dto.diskLimit = j.getString("diskLimit");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDevSpace(tenantId, dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Dev space created");

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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DevSpaceDTO dto;
            dto.id = DevSpaceId(precheck.id);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.extensions = j.getString("extensions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDevSpace(tenantId, dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Dev space updated");

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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DevSpaceId(precheck.id);
            auto result = usecase.deleteDevSpace(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Dev space deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
