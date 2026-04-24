/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryProjectTemplateRepository : TenantRepository!(ProjectTemplate, ProjectTemplateId), ProjectTemplateRepository {

    size_t countByCategory(TemplateCategory category) {
        return findByCategory(category).length;
    }

    ProjectTemplate[] findByCategory(TemplateCategory category) {
        return findAll().filter!(e => e.category == category).array;
    }

    void removeByCategory(TemplateCategory category) {
        findByCategory(category).each!(e => remove(e));
    }
}
