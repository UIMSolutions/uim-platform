/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.project_templates;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class MemoryProjectTemplateRepository : TenantRepository!(ProjectTemplate, ProjectTemplateId), ProjectTemplateRepository {

    size_t countByCategory(TenantId tenantId, TemplateCategory category) {
        return findByCategory(tenantId, category).length;
    }

    ProjectTemplate[] findByCategory(TenantId tenantId, TemplateCategory category) {
        return find(tenantId).filter!(e => e.category == category).array;
    }

    void removeByCategory(TenantId tenantId, TemplateCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }
}
