/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface ProjectTemplateRepository {
    bool existsById(ProjectTemplateId id);
    ProjectTemplate findById(ProjectTemplateId id);

    ProjectTemplate[] findAll();
    ProjectTemplate[] findByTenant(TenantId tenantId);
    ProjectTemplate[] findByCategory(TemplateCategory category);

    void save(ProjectTemplate entity);
    void update(ProjectTemplate entity);
    void remove(ProjectTemplateId id);
}
