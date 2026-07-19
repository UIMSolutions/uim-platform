/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.persistence.repositories.translation_projects;

import uim.platform.translation;
mixin(ShowModule!());

@safe:

class MemoryTranslationProjectRepository : TenantRepository!(TranslationProject, TranslationProjectId),
TranslationProjectRepository {
    
    bool existsByName(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(p => p.name == name);
    }

    TranslationProject findByName(TenantId tenantId, string name) {
        foreach (p; findByTenant(tenantId))
            if (p.name == name)
                return p;
        return TranslationProject.init;
    }

    void removeByName(TenantId tenantId, string name) {
        foreach (p; findByTenant(tenantId))
            if (p.name == name) {
                super.remove(p.id);
                return;
            }
    }
}
