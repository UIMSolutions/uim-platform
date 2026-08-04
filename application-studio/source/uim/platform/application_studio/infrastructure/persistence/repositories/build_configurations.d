/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing BuildConfiguration entities in the persistence layer.
class BuildConfigurationRepository : TenantRepository!(BuildConfiguration, BuildConfigurationId), IBuildConfigurationRepository {

    // #region ByProject
    size_t countByProject(TenantId tenantId, ProjectId projectId) {
        return findByProject(tenantId, projectId).length;
    }   

    BuildConfiguration[] filterByProject(BuildConfiguration[] configs, ProjectId projectId) {
        return configs.filter!(e => e.projectId == projectId).array;
    }

    BuildConfiguration[] findByProject(TenantId tenantId, ProjectId projectId) {
        return filterByProject(findByTenant(tenantId), projectId);
    }

    void removeByProject(TenantId tenantId, ProjectId projectId) {
        findByProject(tenantId, projectId).each!(e => remove(e));
    }
    // #endregion ByProject

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, BuildStatus status) {
        return findByStatus(tenantId, status).length;
    }

    BuildConfiguration[] filterByStatus(BuildConfiguration[] configs, BuildStatus status) {
        return configs.filter!(e => e.status == status).array;
    }

    BuildConfiguration[] findByStatus(TenantId tenantId, BuildStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, BuildStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
///
unittest {
    mixin(ShowTest!("Running BuildConfigurationRepository tests..."));

    void testCountByProject(IBuildConfigurationRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto entity1 = BuildConfiguration(tenantId, BuildConfigurationId("bc1"));
        entity1.projectId = ProjectId("proj1");
        entity1.name = "BuildConfig 1";
        auto entity2 = BuildConfiguration(tenantId, BuildConfigurationId("bc2"));
        entity2.projectId = ProjectId("proj2");
        entity2.name = "BuildConfig 2";
        auto entity3 = BuildConfiguration(tenantId, BuildConfigurationId("bc3"));
        entity3.projectId = ProjectId("proj1");
        entity3.name = "BuildConfig 3";

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test countByProject
        assert(repo.countByProject(tenantId, ProjectId("proj1")) == 2);
        assert(repo.countByProject(tenantId, ProjectId("proj2")) == 1);
    }

    void testFindByProject(IBuildConfigurationRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto entity1 = BuildConfiguration(tenantId, BuildConfigurationId("bc1"));
        entity1.projectId = ProjectId("proj1");
        entity1.name = "BuildConfig 1";
        auto entity2 = BuildConfiguration(tenantId, BuildConfigurationId("bc2"));
        entity2.projectId = ProjectId("proj2");
        entity2.name = "BuildConfig 2";
        auto entity3 = BuildConfiguration(tenantId, BuildConfigurationId("bc3"));
        entity3.projectId = ProjectId("proj1");
        entity3.name = "BuildConfig 3";

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test findByProject
        auto proj1Configs = repo.findByProject(tenantId, ProjectId("proj1"));
        assert(proj1Configs.length == 2);
        assert(proj1Configs.canFind!(c => c.id == BuildConfigurationId("bc1")));
        assert(proj1Configs.canFind!(c => c.id == BuildConfigurationId("bc3")));

        auto proj2Configs = repo.findByProject(tenantId, ProjectId("proj2"));
        assert(proj2Configs.length == 1);
        assert(proj2Configs[0].id == BuildConfigurationId("bc2"));
    }

    void testRemoveByProject(IBuildConfigurationRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto entity1 = BuildConfiguration(tenantId, BuildConfigurationId("bc1"));
        entity1.projectId = ProjectId("proj1");
        entity1.name = "BuildConfig 1";
        auto entity2 = BuildConfiguration(tenantId, BuildConfigurationId("bc2"));
        entity2.projectId = ProjectId("proj2");
        entity2.name = "BuildConfig 2";
        auto entity3 = BuildConfiguration(tenantId, BuildConfigurationId("bc3"));
        entity3.projectId = ProjectId("proj1");
        entity3.name = "BuildConfig 3";

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test removeByProject
        repo.removeByProject(tenantId, ProjectId("proj1"));
        assert(repo.countByProject(tenantId, ProjectId("proj1")) == 0);
        assert(repo.countByProject(tenantId, ProjectId("proj2")) == 1);
    }

    void testCountByStatus(IBuildConfigurationRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto entity1 = BuildConfiguration(tenantId, BuildConfigurationId("bc1"));
        entity1.status = BuildStatus.pending;
        auto entity2 = BuildConfiguration(tenantId, BuildConfigurationId("bc2"));
        entity2.status = BuildStatus.succeeded;
        auto entity3 = BuildConfiguration(tenantId, BuildConfigurationId("bc3"));
        entity3.status = BuildStatus.pending;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test countByStatus
        assert(repo.countByStatus(tenantId, BuildStatus.pending) == 2);
        assert(repo.countByStatus(tenantId, BuildStatus.succeeded) == 1);
    }

    void testFindByStatus(IBuildConfigurationRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto entity1 = BuildConfiguration(tenantId, BuildConfigurationId("bc1"));
        entity1.status = BuildStatus.pending;
        auto entity2 = BuildConfiguration(tenantId, BuildConfigurationId("bc2"));
        entity2.status = BuildStatus.succeeded;
        auto entity3 = BuildConfiguration(tenantId, BuildConfigurationId("bc3"));
        entity3.status = BuildStatus.pending;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test findByStatus
        auto pendingConfigs = repo.findByStatus(tenantId, BuildStatus.pending);
        assert(pendingConfigs.length == 2);
        assert(pendingConfigs.canFind!(c => c.id == BuildConfigurationId("bc1")));
        assert(pendingConfigs.canFind!(c => c.id == BuildConfigurationId("bc3")));

        auto successConfigs = repo.findByStatus(tenantId, BuildStatus.succeeded);
        assert(successConfigs.length == 1);
        assert(successConfigs[0].id == BuildConfigurationId("bc2"));
    }

    void testRemoveByStatus(IBuildConfigurationRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto entity1 = BuildConfiguration(tenantId, BuildConfigurationId("bc1"));
        entity1.status = BuildStatus.pending;
        auto entity2 = BuildConfiguration(tenantId, BuildConfigurationId("bc2"));
        entity2.status = BuildStatus.succeeded;
        auto entity3 = BuildConfiguration(tenantId, BuildConfigurationId("bc3"));
        entity3.status = BuildStatus.pending;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test removeByStatus
        repo.removeByStatus(tenantId, BuildStatus.pending);
        assert(repo.countByStatus(tenantId, BuildStatus.pending) == 0);
        assert(repo.countByStatus(tenantId, BuildStatus.succeeded) == 1);
    }

    void runAllTests() {
        testCountByProject(new BuildConfigurationRepository());
        testFindByProject(new BuildConfigurationRepository());
        testRemoveByProject(new BuildConfigurationRepository());

        testCountByStatus(new BuildConfigurationRepository());
        testFindByStatus(new BuildConfigurationRepository());
        testRemoveByStatus(new BuildConfigurationRepository());
    }

    runAllTests();
}