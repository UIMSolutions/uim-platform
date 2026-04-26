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


    size_t countByTechnician(TechnicianId technicianId) {
        return findByTechnician(technicianId).length;
    }
    Skill[] filterByTechnician(Skill[] skills, TechnicianId technicianId) {
        return skills.filter!(e => e.technicianId == technicianId).array;
    }
    Skill[] findByTechnician(TechnicianId technicianId) {
        return filterByTechnician(findAll(), technicianId);
    }
    void removeByTechnician(TechnicianId technicianId) {
        findByTechnician(technicianId).each!(e => remove(e));
    }

    size_t countByCategory(SkillCategory category) {
        return findByCategory(category).length;
    }
    Skill[] filterByCategory(Skill[] skills, SkillCategory category) {
        return skills.filter!(e => e.category == category).array;
    }
    Skill[] findByCategory(SkillCategory category) {
        return filterByCategory(findAll(), category);
    }
    void removeByCategory(SkillCategory category) {
        findByCategory(category).each!(e => remove(e));
    }

}
