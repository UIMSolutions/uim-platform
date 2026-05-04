/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.skill;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class SkillController : PlatformController {
    private ManageSkillsUseCase uc;

    this(ManageSkillsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/field-service/skills", &handleList);
        router.get("/api/v1/field-service/skills/*", &handleGet);
        router.post("/api/v1/field-service/skills", &handleCreate);
        router.put("/api/v1/field-service/skills/*", &handleUpdate);
        router.delete_("/api/v1/field-service/skills/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => skillToJson(e)).array;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Skills retrieved successfully");
              
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
            auto e = uc.getById(id);
            if (e.isNull) { writeError(res, 404, "Skill not found"); return; }
            res.writeJsonBody(skillToJson(e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            SkillDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.technicianId = j.getString("technicianId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.category = j.getString("category");
            dto.proficiencyLevel = j.getString("proficiencyLevel");
            dto.certificationDate = j.getString("certificationDate");
            dto.expirationDate = j.getString("expirationDate");
            dto.certificationNumber = j.getString("certificationNumber");
            dto.issuingAuthority = j.getString("issuingAuthority");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Skill created"));

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
            SkillDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.certificationDate = j.getString("certificationDate");
            dto.expirationDate = j.getString("expirationDate");
            dto.issuingAuthority = j.getString("issuingAuthority");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Skill updated");

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
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Skill deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
