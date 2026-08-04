/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing RunConfiguration entities in a multi-tenant environment.
class RunConfigurationRepository : TenantRepository!(RunConfiguration, RunConfigurationId), IRunConfigurationRepository {

    size_t countByProject(TenantId tenantId, ProjectId projectId) {
        return findByProject(tenantId, projectId).length;
    }

    RunConfiguration[] filterByProject(RunConfiguration[] configs, ProjectId projectId) {
        return configs.filter!(c => c.projectId == projectId).array;
    }

    RunConfiguration[] findByProject(TenantId tenantId, ProjectId projectId) {
        return filterByProject(findByTenant(tenantId), projectId);
    }

    void removeByProject(TenantId tenantId, ProjectId projectId) {
        findByProject(tenantId, projectId).each!(c => remove(c));
    }
}
///
unittest {
    mixin(ShowTest!("Running RunConfigurationRepository tests..."));

    void testCountByProject() {
        auto tenantId = TenantId("tenant1");
        auto repo = new RunConfigurationRepository();

        // Create test entities
        auto entity1 = RunConfiguration(RunConfigurationId("rc1"), tenantId, ProjectId("proj1"), "RunConfig 1");
        auto entity2 = RunConfiguration(RunConfigurationId("rc2"), tenantId, ProjectId("proj2"), "RunConfig 2");
        auto entity3 = RunConfiguration(RunConfigurationId("rc3"), tenantId, ProjectId("proj1"), "RunConfig 3");

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test countByProject
        assert(repo.countByProject(tenantId, ProjectId("proj1")) == 2);
        assert(repo.countByProject(tenantId, ProjectId("proj2")) == 1);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testFindByProject() {
        auto tenantId = TenantId("tenant1");
        auto repo = new RunConfigurationRepository();

        // Create test entities
        auto entity1 = RunConfiguration(RunConfigurationId("rc1"), tenantId, ProjectId("proj1"), "RunConfig 1");
        auto entity2 = RunConfiguration(RunConfigurationId("rc2"), tenantId, ProjectId("proj2"), "RunConfig 2");
        auto entity3 = RunConfiguration(RunConfigurationId("rc3"), tenantId, ProjectId("proj1"), "RunConfig 3");

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test findByProject
        auto proj1Configs = repo.findByProject(tenantId, ProjectId("proj1"));
        assert(proj1Configs.length == 2);
        assert(proj1Configs.canFind!(c => c.id == RunConfigurationId("rc1")));
        assert(proj1Configs.canFind!(c => c.id == RunConfigurationId("rc3")));

        auto proj2Configs = repo.findByProject(tenantId, ProjectId("proj2"));
        assert(proj2Configs.length == 1);
        assert(proj2Configs[0].id == RunConfigurationId("rc2"));

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testRemoveByProject() {
        auto tenantId = TenantId("tenant1");
        auto repo = new RunConfigurationRepository();

        // Create test entities
        auto entity1 = RunConfiguration(RunConfigurationId("rc1"), tenantId, ProjectId("proj1"), "RunConfig 1");
        auto entity2 = RunConfiguration(RunConfigurationId("rc2"), tenantId, ProjectId("proj2"), "RunConfig 2");
        auto entity3 = RunConfiguration(RunConfigurationId("rc3"), tenantId, ProjectId("proj1"), "RunConfig 3");

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test removeByProject
        repo.removeByProject(tenantId, ProjectId("proj1"));
        assert(repo.countByProject(tenantId, ProjectId("proj1")) == 0);
        assert(repo.countByProject(tenantId, ProjectId("proj2")) == 1);

        // Clean up
        repo.remove(entity2);
    }

    void runAllTests() {
        testCountByProject();
        testFindByProject();
        testRemoveByProject();
    }

    runAllTests();
}
