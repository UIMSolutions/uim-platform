/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing ProjectTemplate entities in a multi-tenant environment.
class ProjectTemplateRepository : TenantRepository!(ProjectTemplate, ProjectTemplateId), IProjectTemplateRepository {

    size_t countByCategory(TenantId tenantId, TemplateCategory category) {
        return findByCategory(tenantId, category).length;
    }

    ProjectTemplate[] filterByCategory(ProjectTemplate[] templates, TemplateCategory category) {
        return templates.filter!(e => e.category == category).array;
    }

    ProjectTemplate[] findByCategory(TenantId tenantId, TemplateCategory category) {
        return filterByCategory(findByTenant(tenantId), category);
    }

    void removeByCategory(TenantId tenantId, TemplateCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }
}
///
unittest {
    mixin(ShowTest!("Running ProjectTemplateRepository tests..."));

    void testCountByCategory(IProjectTemplateRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto category = "sapFiori".toTemplateCategory;

        auto projectTemplate1 = ProjectTemplate(tenantId);
        projectTemplate1.category = category;
        projectTemplate1.name = "template1";
        projectTemplate1.title = "Template 1";
        projectTemplate1.description = "Description 1";

        auto projectTemplate2 = ProjectTemplate(tenantId);
        projectTemplate2.category = category;
        projectTemplate2.name = "template2";
        projectTemplate2.title = "Template 2";
        projectTemplate2.description = "Description 2";

        auto projectTemplate3 = ProjectTemplate(tenantId);
        projectTemplate3.category = "sapHana".toTemplateCategory;
        projectTemplate3.name = "template3";
        projectTemplate3.title = "Template 3";
        projectTemplate3.description = "Description 3";

        repo.save(projectTemplate1);
        repo.save(projectTemplate2);
        repo.save(projectTemplate3);

        assert(repo.countByCategory(tenantId, category) == 2);
    }

    void testFindByCategory(IProjectTemplateRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto category = "sapFiori".toTemplateCategory;

        auto projectTemplate1 = ProjectTemplate(tenantId);
        projectTemplate1.category = category;
        projectTemplate1.name = "template1";
        projectTemplate1.title = "Template 1";
        projectTemplate1.description = "Description 1";
        auto projectTemplate2 = ProjectTemplate(tenantId);
        projectTemplate2.category = category;
        projectTemplate2.name = "template2";
        projectTemplate2.title = "Template 2";
        projectTemplate2.description = "Description 2";
        auto projectTemplate3 = ProjectTemplate(tenantId);
        projectTemplate3.category = "sapHana".toTemplateCategory;
        projectTemplate3.name = "template3";
        projectTemplate3.title = "Template 3";
        projectTemplate3.description = "Description 3";

        repo.save(projectTemplate1);
        repo.save(projectTemplate2);
        repo.save(projectTemplate3);

        auto templates = repo.findByCategory(tenantId, category);
        assert(templates.length == 2);
        assert(templates[0].id == projectTemplate1.id || templates[0].id == projectTemplate2.id);
        assert(templates[1].id == projectTemplate1.id || templates[1].id == projectTemplate2.id);   

    }

    void testRemoveByCategory(IProjectTemplateRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto category = "sapFiori".toTemplateCategory;

        auto projectTemplate1 = ProjectTemplate(tenantId);
        projectTemplate1.category = category;
        projectTemplate1.name = "template1";
        projectTemplate1.title = "Template 1";
        projectTemplate1.description = "Description 1";
        auto projectTemplate2 = ProjectTemplate(tenantId);
        projectTemplate2.category = category;
        projectTemplate2.name = "template2";
        projectTemplate2.title = "Template 2";
        projectTemplate2.description = "Description 2";
        auto projectTemplate3 = ProjectTemplate(tenantId);
        projectTemplate3.category = "sapHana".toTemplateCategory;
        projectTemplate3.name = "template3";
        projectTemplate3.title = "Template 3";
        projectTemplate3.description = "Description 3";

        repo.save(projectTemplate1);
        repo.save(projectTemplate2);
        repo.save(projectTemplate3);

        repo.removeByCategory(tenantId, category);

        auto templates = repo.findByCategory(tenantId, category);
        assert(templates.length == 0);
    }
}
