/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageSkillsUseCase {
    private ISkillRepository repo;

    this(ISkillRepository repo) {
        this.repo = repo;
    }

    Skill getSkill(TenantId tenantId, SkillId id) {
        return repo.findById(tenantId, id);
    }

    Skill[] listSkills(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Skill[] listSkills(TenantId tenantId, TechnicianId technicianId) {
        return repo.findByTechnician(tenantId, technicianId);
    }

    Skill[] listSkills(TenantId tenantId, SkillCategory category) {
        return repo.findByCategory(tenantId, category);
    }

    UsecaseResult createSkill(SkillDTO dto) {
        Skill s;
        s.id = dto.skillId;
        s.tenantId = dto.tenantId;
        s.technicianId = dto.technicianId;
        s.name = dto.name;
        s.description = dto.description;
        s.certificationDate = dto.certificationDate;
        s.expirationDate = dto.expirationDate;
        s.certificationNumber = dto.certificationNumber;
        s.issuingAuthority = dto.issuingAuthority;
        s.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidSkill(s))
            return UsecaseResult(false, "", "Invalid skill data");
        repo.save(s);
        return UsecaseResult(true, s.id.value, "");
    }

    UsecaseResult updateSkill(SkillDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.skillId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Skill not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.certificationDate.length > 0) existing.certificationDate = dto.certificationDate;
        if (dto.expirationDate.length > 0) existing.expirationDate = dto.expirationDate;
        if (dto.certificationNumber.length > 0) existing.certificationNumber = dto.certificationNumber;
        if (dto.issuingAuthority.length > 0) existing.issuingAuthority = dto.issuingAuthority;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteSkill(TenantId tenantId, SkillId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Skill not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}
