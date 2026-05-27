/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.skill;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class SkillController : ManageController {
    private ManageSkillsUseCase usecase;

    this(ManageSkillsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/skills", &handleList);
        router.get("/api/v1/field-service/skills/*", &handleGet);
        router.post("/api/v1/field-service/skills", &handleCreate);
        router.put("/api/v1/field-service/skills/*", &handleUpdate);
        router.delete_("/api/v1/field-service/skills/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listSkills(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Skills retrieved successfully");
              
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = SkillId(precheck.id);
            auto e = usecase.getSkill(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Skill not found"); return; }
            res.writeJsonBody(e.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            SkillDTO dto;
            dto.skillId = SkillId(precheck.id);
            dto.tenantId = tenantId;
            dto.technicianId = TechnicianId(j.getString("technicianId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.category = j.getString("category");
            dto.proficiencyLevel = j.getString("proficiencyLevel");
            dto.certificationDate = j.getString("certificationDate");
            dto.expirationDate = j.getString("expirationDate");
            dto.certificationNumber = j.getString("certificationNumber");
            dto.issuingAuthority = j.getString("issuingAuthority");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createSkill(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Skill created");

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
            SkillDTO dto;
            dto.skillId = SkillId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.certificationDate = j.getString("certificationDate");
            dto.expirationDate = j.getString("expirationDate");
            dto.issuingAuthority = j.getString("issuingAuthority");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateSkill(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Skill updated");

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
            auto id = SkillId(precheck.id);
            auto result = usecase.deleteSkill(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Skill deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
