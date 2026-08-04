/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing Project entities in a multi-tenant environment.
class ProjectRepository : TenantRepository!(Project, ProjectId), IProjectRepository {

    // #region ByType
    size_t countByType(TenantId tenantId, ProjectType projectType) {
        return findByType(tenantId, projectType).length;
    }

    Project[] filterByType(Project[] projects, ProjectType projectType) {
        return projects.filter!(p => p.projectType == projectType).array;
    }

    Project[] findByType(TenantId tenantId, ProjectType projectType) {
        return filterByType(findByTenant(tenantId), projectType);
    }

    void removeByType(TenantId tenantId, ProjectType projectType) {
        findByType(tenantId, projectType).each!(e => remove(e));
    }
    // #endregion ByType

    // #region ByDevSpace
    size_t countByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return findByDevSpace(tenantId, devSpaceId).length;
    }

    Project[] filterByDevSpace(Project[] projects, DevSpaceId devSpaceId) {
        return projects.filter!(p => p.devSpaceId == devSpaceId).array;
    }

    Project[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return filterByDevSpace(findByTenant(tenantId), devSpaceId);
    }

    void removeByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        findByDevSpace(tenantId, devSpaceId).each!(e => remove(e));
    }
    // #endregion ByDevSpace
}
///
unittest {
    mixin(ShowTest!("Running ProjectRepository tests..."));

    void testCountByType(IProjectRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto projectType = "sapFiori".toProjectType;

        // Create test entities for tenant: ", tenantId, " and project type: ", projectType);
        auto project1 = Project(tenantId, ProjectId("project1"));
        project1.projectType = projectType;
        project1.devSpaceId = DevSpaceId("devspace1");
        auto project2 = Project(tenantId, ProjectId("project2"));
        project2.projectType = projectType;
        project2.devSpaceId = DevSpaceId("devspace2");
        auto project3 = Project(tenantId, ProjectId("project3"));
        project3.projectType = "workflow".toProjectType;
        project3.devSpaceId = DevSpaceId("devspace1");

        repo.save(project1);
        repo.save(project2);
        repo.save(project3);

        // Count projects by type
        auto countWebApp = repo.countByType(tenantId, projectType);
        assert(countWebApp == 2);

        auto countMobileApp = repo.countByType(tenantId, "workflow".toProjectType);
        assert(countMobileApp == 1);

        // Clean up
        repo.remove(project1);
        repo.remove(project2);
        repo.remove(project3);

        assert(repo.countByType(tenantId, projectType) == 0);
        assert(repo.countByType(tenantId, "workflow".toProjectType) == 0);
    }

    void testFindByDevSpace(IProjectRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        // Create test entities for tenant: ", tenantId, " and dev space: ", devSpaceId);
        auto project1 = Project(tenantId, ProjectId("project1"));
        project1.projectType = "sapFiori".toProjectType;
        project1.devSpaceId = devSpaceId;
        auto project2 = Project(tenantId, ProjectId("project2"));
        project2.projectType = "workflow".toProjectType;
        project2.devSpaceId = devSpaceId;
        auto project3 = Project(tenantId, ProjectId("project3"));
        project3.projectType = "sapFiori".toProjectType;
        project3.devSpaceId = DevSpaceId("devspace2");

        repo.save(project1);
        repo.save(project2);
        repo.save(project3);

        // Find projects by dev space
        auto projectsInDevSpace1 = repo.findByDevSpace(tenantId, devSpaceId);
        assert(projectsInDevSpace1.length == 2);
        assert(projectsInDevSpace1.canFind(project1));
        assert(projectsInDevSpace1.canFind(project2));

        // Clean up
        repo.remove(project1);
        repo.remove(project2);
        repo.remove(project3);

        assert(repo.findByDevSpace(tenantId, devSpaceId).length == 0);
    }

    void testRemoveByType(IProjectRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto projectType = "sapFiori".toProjectType;

        // Create test entities for tenant: ", tenantId, " and project type: ", projectType);
        auto project1 = Project(tenantId, ProjectId("project1"));
        project1.projectType = projectType;
        project1.devSpaceId = DevSpaceId("devspace1");

        auto project2 = Project(tenantId, ProjectId("project2"));
        project2.projectType = projectType;
        project2.devSpaceId = DevSpaceId("devspace2");

        auto project3 = Project(tenantId, ProjectId("project3"));
        project3.projectType = "workflow".toProjectType;
        project3.devSpaceId = DevSpaceId("devspace1");

        repo.save(project1);
        repo.save(project2);
        repo.save(project3);

        // Remove projects by type
        repo.removeByType(tenantId, projectType);

        // Verify removal
        assert(repo.countByType(tenantId, projectType) == 0);
        assert(repo.countByType(tenantId, "workflow".toProjectType) == 1);

        // Clean up remaining entity
        repo.remove(project3);
        assert(repo.countByType(tenantId, "workflow".toProjectType) == 0);
    }

    void testRemoveByDevSpace(IProjectRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        // Create test entities for tenant: ", tenantId, " and dev space: ", devSpaceId);
        auto project1 = Project(tenantId, ProjectId("project1"));
        project1.projectType = "sapFiori".toProjectType;
        project1.devSpaceId = devSpaceId;

        auto project2 = Project(tenantId, ProjectId("project2"));
        project2.projectType = "workflow".toProjectType;
        project2.devSpaceId = devSpaceId;

        auto project3 = Project(tenantId, ProjectId("project3"));
        project3.projectType = "sapFiori".toProjectType;
        project3.devSpaceId = DevSpaceId("devspace2");

        repo.save(project1);
        repo.save(project2);
        repo.save(project3);

        // Remove projects by dev space
        repo.removeByDevSpace(tenantId, devSpaceId);

        // Verify removal
        assert(repo.countByDevSpace(tenantId, devSpaceId) == 0);
        assert(repo.countByDevSpace(tenantId, DevSpaceId("devspace2")) == 1);

        // Clean up remaining entity
        repo.remove(project3);
        assert(repo.countByDevSpace(tenantId, DevSpaceId("devspace2")) == 0);
    }

        void testFindByDevSpace(IProjectRepository repo) {
            auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        // Create test entities for tenant: ", tenantId, " and dev space: ", devSpaceId);
        auto project1 = Project(tenantId, ProjectId("project1"));
        project1.projectType = "sapFiori".toProjectType;
        project1.devSpaceId = devSpaceId;

        auto project2 = Project(tenantId, ProjectId("project2"));
        project2.projectType = "workflow".toProjectType;
        project2.devSpaceId = devSpaceId;

        auto project3 = Project(tenantId, ProjectId("project3"));
        project3.projectType = "sapFiori".toProjectType;
        project3.devSpaceId = DevSpaceId("devspace2");

        repo.save(project1);
        repo.save(project2);
        repo.save(project3);

        // Find projects by dev space
        auto projectsInDevSpace1 = repo.findByDevSpace(tenantId, devSpaceId);
        assert(projectsInDevSpace1.length == 2);
        assert(projectsInDevSpace1.canFind(project1));
        assert(projectsInDevSpace1.canFind(project2));

        // Clean up
        repo.remove(project1);
        repo.remove(project2);
        repo.remove(project3);

        assert(repo.findByDevSpace(tenantId, devSpaceId).length == 0);
    }

    void testRemoveByDevSpace(IProjectRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        // Create test entities for tenant: ", tenantId, " and dev space: ", devSpaceId);
        auto project1 = Project(tenantId, ProjectId("project1"));
        project1.projectType = "sapFiori".toProjectType;
        project1.devSpaceId = devSpaceId;

        auto project2 = Project(tenantId, ProjectId("project2"));
        project2.projectType = "workflow".toProjectType;
        project2.devSpaceId = devSpaceId;

        auto project3 = Project(tenantId, ProjectId("project3"));
        project3.projectType = "sapFiori".toProjectType;
        project3.devSpaceId = DevSpaceId("devspace2");

        repo.save(project1);
        repo.save(project2);
        repo.save(project3);

        // Remove projects by dev space
        repo.removeByDevSpace(tenantId, devSpaceId);

        // Verify removal
        assert(repo.countByDevSpace(tenantId, devSpaceId) == 0);
        assert(repo.countByDevSpace(tenantId, DevSpaceId("devspace2")) == 1);

        // Clean up remaining entity
        repo.remove(project3);
        assert(repo.countByDevSpace(tenantId, DevSpaceId("devspace2")) == 0);
    }

    void runAllTests() {
        testCountByType(new ProjectRepository());
        testFindByType(new ProjectRepository());
        testRemoveByType(new ProjectRepository());

        testCountByDevSpace(new ProjectRepository());
        testFindByDevSpace(new ProjectRepository());
        testRemoveByDevSpace(new ProjectRepository());
    }
}
        
