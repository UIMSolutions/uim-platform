/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemorySkillRepository : TenantRepository!(Skill, SkillId), SkillRepository {


    size_t countByTechnician(TenantId tenantId, TechnicianId technicianId) {
        return findByTechnician(tenantId, technicianId).length;
    }
    Skill[] filterByTechnician(Skill[] skills, TechnicianId technicianId) {
        return skills.filter!(e => e.technicianId == technicianId).array;
    }
    Skill[] findByTechnician(TenantId tenantId, TechnicianId technicianId) {
        return filterByTechnician(find(tenantId), technicianId);
    }
    void removeByTechnician(TenantId tenantId, TechnicianId technicianId) {
        findByTechnician(tenantId, technicianId).each!(e => remove(e));
    }

    size_t countByCategory(TenantId tenantId, SkillCategory category) {
        return findByCategory(tenantId, category).length;
    }
    Skill[] filterByCategory(Skill[] skills, SkillCategory category) {
        return skills.filter!(e => e.category == category).array;
    }
    Skill[] findByCategory(TenantId tenantId, SkillCategory category) {
        return filterByCategory(find(tenantId), category);
    }
    void removeByCategory(TenantId tenantId, SkillCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }

}
