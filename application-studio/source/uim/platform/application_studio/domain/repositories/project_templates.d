/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface ProjectTemplateRepository : ITenantRepository!(ProjectTemplate, ProjectTemplateId) {

    size_t countByCategoryCount(TemplateCategory category);
    ProjectTemplate[] findByCategory(TemplateCategory category, size_t offset = 0, size_t limit = 100);
    void removeByCategory(TemplateCategory category);

}
