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
    mixin TenantEntity!SkillId;

    TechnicianId technicianId;
    string name;
    string description;
    SkillCategory category = SkillCategory.technical;
    ProficiencyLevel proficiencyLevel = ProficiencyLevel.intermediate;
    string certificationDate;
    string expirationDate;
    string certificationNumber;
    string issuingAuthority;
    
    Json toJson() const {
        return entityToJson
            .set("technicianId", technicianId)
            .set("name", name)
            .set("description", description)
            .set("category", category.to!string())
            .set("proficiencyLevel", proficiencyLevel.to!string())
            .set("certificationDate", certificationDate)
            .set("expirationDate", expirationDate)
            .set("certificationNumber", certificationNumber)
            .set("issuingAuthority", issuingAuthority);
    }

}
