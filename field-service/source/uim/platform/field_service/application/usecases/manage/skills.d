/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageSkillsUseCase { // TODO: UIMUseCase {
    private SkillRepository repo;

    this(SkillRepository repo) {
        this.repo = repo;
    }

    Skill* getById(SkillId id) {
        return repo.findById(id);
    }

    Skill[] list() {
        return repo.findAll();
    }

    Skill[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Skill[] listByTechnician(TechnicianId technicianId) {
        return repo.findByTechnician(technicianId);
    }

    Skill[] listByCategory(SkillCategory category) {
        return repo.findByCategory(category);
    }

    CommandResult create(SkillDTO dto) {
        Skill s;
        s.id = dto.id;
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
            return CommandResult(false, "", "Invalid skill data");
        repo.save(s);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(SkillDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing.isNull)
            return CommandResult(false, "", "Skill not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.certificationDate.length > 0) existing.certificationDate = dto.certificationDate;
        if (dto.expirationDate.length > 0) existing.expirationDate = dto.expirationDate;
        if (dto.issuingAuthority.length > 0) existing.issuingAuthority = dto.issuingAuthority;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(SkillId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Skill not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
