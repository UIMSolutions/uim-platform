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
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Skills retrieved successfully", "Retrieved", 200, resp);

    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SkillId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid skill ID", 400);

        auto e = usecase.getSkill(tenantId, id);

        if (e.isNull)
            return errorResponse("Skill not found", 404);

        return successResponse("Skill retrieved successfully", "Retrieved", 200, e.toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        SkillDTO dto;
        dto.skillId = SkillId(precheck.id);
        dto.tenantId = tenantId;
        dto.technicianId = TechnicianId(data.getString("technicianId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.category = data.getString("category");
        dto.proficiencyLevel = data.getString("proficiencyLevel");
        dto.certificationDate = data.getString("certificationDate");
        dto.expirationDate = data.getString("expirationDate");
        dto.certificationNumber = data.getString("certificationNumber");
        dto.issuingAuthority = data.getString("issuingAuthority");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createSkill(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Skill created successfully", "Created", 201, resp);

    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        SkillDTO dto;
        dto.skillId = SkillId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.certificationDate = data.getString("certificationDate");
        dto.expirationDate = data.getString("expirationDate");
        dto.issuingAuthority = data.getString("issuingAuthority");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateSkill(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Skill updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SkillId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid skill ID", 400);

        auto result = usecase.deleteSkill(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Skill deleted successfully", 200, responseData);
    }
}
