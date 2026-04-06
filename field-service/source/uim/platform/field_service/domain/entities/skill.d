/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.skill;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Skill {
    SkillId id;
    TenantId tenantId;
    TechnicianId technicianId;
    string name;
    string description;
    SkillCategory category = SkillCategory.technical;
    ProficiencyLevel proficiencyLevel = ProficiencyLevel.intermediate;
    string certificationDate;
    string expirationDate;
    string certificationNumber;
    string issuingAuthority;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
