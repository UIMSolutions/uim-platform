/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing DevSpace entities in a multi-tenant environment.
class DevSpaceRepository : TenantRepository!(DevSpace, DevSpaceId), IDevSpaceRepository {

    // #region ByOwner
    size_t countByOwner(TenantId tenantId, string owner) {
        return findByOwner(tenantId, owner).length;
    }

    DevSpace[] filterByOwner(DevSpace[] devSpaces, string owner) {
        return devSpaces.filter!(ds => ds.owner == owner).array;
    }

    DevSpace[] findByOwner(TenantId tenantId, string owner) {
        return filterByOwner(findByTenant(tenantId), owner);
    }

    void removeByOwner(TenantId tenantId, string owner) {
        findByOwner(tenantId, owner).each!(e => remove(e));
    }
    // #endregion ByOwner

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, DevSpaceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    DevSpace[] filterByStatus(DevSpace[] devSpaces, DevSpaceStatus status) {
        return devSpaces.filter!(ds => ds.status == status).array;
    }

    DevSpace[] findByStatus(TenantId tenantId, DevSpaceStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, DevSpaceStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
unittest {
    mixin(ShowTest!("Running DevSpaceRepository tests..."));

    void testCountByOwner(IDevSpaceRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto devSpace1 = DevSpace(tenantId, DevSpaceId("ds1"));
        devSpace1.owner = "owner1";
        devSpace1.status = DevSpaceStatus.starting;

        auto devSpace2 = DevSpace(tenantId, DevSpaceId("ds2"));
        devSpace2.owner = "owner1";
        devSpace2.status = DevSpaceStatus.stopping;

        auto devSpace3 = DevSpace(tenantId, DevSpaceId("ds3"));
        devSpace3.owner = "owner2";
        devSpace3.status = DevSpaceStatus.starting;

        // Add entities to the repository
        repo.save(devSpace1);
        repo.save(devSpace2);
        repo.save(devSpace3);

        // Test countByOwner
        assert(repo.countByOwner(tenantId, "owner1") == 2);
        assert(repo.countByOwner(tenantId, "owner2") == 1);
        assert(repo.countByOwner(tenantId, "nonexistent") == 0);
    }

    void testFindByOwner(IDevSpaceRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto devSpace1 = DevSpace(tenantId, DevSpaceId("ds1"));
        devSpace1.owner = "owner1";
        devSpace1.status = DevSpaceStatus.starting;

        auto devSpace2 = DevSpace(tenantId, DevSpaceId("ds2"));
        devSpace2.owner = "owner1";
        devSpace2.status = DevSpaceStatus.stopping;

        auto devSpace3 = DevSpace(tenantId, DevSpaceId("ds3"));
        devSpace3.owner = "owner2";
        devSpace3.status = DevSpaceStatus.starting;

        // Add entities to the repository
        repo.save(devSpace1);
        repo.save(devSpace2);
        repo.save(devSpace3);

        // Test findByOwner
        auto owner1Spaces = repo.findByOwner(tenantId, "owner1");
        assert(owner1Spaces.length == 2);
        assert(owner1Spaces[0] == devSpace1 || owner1Spaces[0] == devSpace2);
        assert(owner1Spaces[1] == devSpace1 || owner1Spaces[1] == devSpace2);

        auto owner2Spaces = repo.findByOwner(tenantId, "owner2");
        assert(owner2Spaces.length == 1);
        assert(owner2Spaces[0] == devSpace3);

        auto nonexistentSpaces = repo.findByOwner(tenantId, "nonexistent");
        assert(nonexistentSpaces.length == 0);
    }

    void testRemoveByOwner(IDevSpaceRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto devSpace1 = DevSpace(tenantId, DevSpaceId("ds1"));
        devSpace1.owner = "owner1";
        devSpace1.status = DevSpaceStatus.starting;

        auto devSpace2 = DevSpace(tenantId, DevSpaceId("ds2"));
        devSpace2.owner = "owner1";
        devSpace2.status = DevSpaceStatus.stopping;

        auto devSpace3 = DevSpace(tenantId, DevSpaceId("ds3"));
        devSpace3.owner = "owner2";
        devSpace3.status = DevSpaceStatus.starting;

        // Add entities to the repository
        repo.save(devSpace1);
        repo.save(devSpace2);
        repo.save(devSpace3);

        // Test removeByOwner
        repo.removeByOwner(tenantId, "owner1");
        assert(repo.countByOwner(tenantId, "owner1") == 0);
        assert(repo.countByOwner(tenantId, "owner2") == 1);
    }

    void testCountByStatus(IDevSpaceRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto devSpace1 = DevSpace(tenantId, DevSpaceId("ds1"));
        devSpace1.owner = "owner1";
        devSpace1.status = DevSpaceStatus.starting;

        auto devSpace2 = DevSpace(tenantId, DevSpaceId("ds2"));
        devSpace2.owner = "owner1";
        devSpace2.status = DevSpaceStatus.stopping;

        auto devSpace3 = DevSpace(tenantId, DevSpaceId("ds3"));
        devSpace3.owner = "owner2";
        devSpace3.status = DevSpaceStatus.starting;

        // Add entities to the repository
        repo.save(devSpace1);
        repo.save(devSpace2);
        repo.save(devSpace3);

        // Test countByStatus
        assert(repo.countByStatus(tenantId, DevSpaceStatus.starting) == 2);
        assert(repo.countByStatus(tenantId, DevSpaceStatus.stopping) == 1);
    }

    void testFindByStatus(IDevSpaceRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto devSpace1 = DevSpace(tenantId, DevSpaceId("ds1"));
        devSpace1.owner = "owner1";
        devSpace1.status = DevSpaceStatus.starting;

        auto devSpace2 = DevSpace(tenantId, DevSpaceId("ds2"));
        devSpace2.owner = "owner1";
        devSpace2.status = DevSpaceStatus.stopping;

        auto devSpace3 = DevSpace(tenantId, DevSpaceId("ds3"));
        devSpace3.owner = "owner2";
        devSpace3.status = DevSpaceStatus.starting;

        // Add entities to the repository
        repo.save(devSpace1);
        repo.save(devSpace2);
        repo.save(devSpace3);

        // Test findByStatus
        auto activeSpaces = repo.findByStatus(tenantId, DevSpaceStatus.starting);
        assert(activeSpaces.length == 2);
        assert(activeSpaces[0] == devSpace1 || activeSpaces[0] == devSpace3);
        assert(activeSpaces[1] == devSpace1 || activeSpaces[1] == devSpace3);

        auto inactiveSpaces = repo.findByStatus(tenantId, DevSpaceStatus.stopping);
        assert(inactiveSpaces.length == 1);
        assert(inactiveSpaces[0] == devSpace2);
    }

    void testRemoveByStatus(IDevSpaceRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto devSpace1 = DevSpace(tenantId, DevSpaceId("ds1"));
        devSpace1.owner = "owner1";
        devSpace1.status = DevSpaceStatus.starting;

        auto devSpace2 = DevSpace(tenantId, DevSpaceId("ds2"));
        devSpace2.owner = "owner1";
        devSpace2.status = DevSpaceStatus.stopping;

        auto devSpace3 = DevSpace(tenantId, DevSpaceId("ds3"));
        devSpace3.owner = "owner2";
        devSpace3.status = DevSpaceStatus.starting;

        // Add entities to the repository
        repo.save(devSpace1);
        repo.save(devSpace2);
        repo.save(devSpace3);

        // Test removeByStatus
        repo.removeByStatus(tenantId, DevSpaceStatus.starting);
        assert(repo.countByStatus(tenantId, DevSpaceStatus.starting) == 0);
        assert(repo.countByStatus(tenantId, DevSpaceStatus.stopping) == 1);
    }

    void runAllTests() {
        testCountByOwner(new DevSpaceRepository());
        testFindByOwner(new DevSpaceRepository());
        testRemoveByOwner(new DevSpaceRepository());

        testCountByStatus(new DevSpaceRepository());
        testFindByStatus(new DevSpaceRepository());
        testRemoveByStatus(new DevSpaceRepository());
    }

    runAllTests();
}
