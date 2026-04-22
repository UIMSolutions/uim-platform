/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface SkillRepository : ITenantRepository!(Skill, SkillId) {

    size_t countByTechnician(TechnicianId technicianId);
    Skill[] findByTechnician(TechnicianId technicianId);
    void removeByTechnician(TechnicianId technicianId);

    size_t countByCategory(SkillCategory category);
    Skill[] findByCategory(SkillCategory category);
    void removeByCategory(SkillCategory category);

}
