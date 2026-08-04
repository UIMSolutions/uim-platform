/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.dev_space_types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing DevSpaceType entities in a multi-tenant environment.
class DevSpaceTypeRepository : TenantRepository!(DevSpaceType, DevSpaceTypeId), IDevSpaceTypeRepository {

    size_t countByCategory(TenantId tenantId, DevSpaceTypeCategory category) {
        return findByCategory(tenantId, category).length;
    }

    DevSpaceType[] filterByCategory(DevSpaceType[] dsts, DevSpaceTypeCategory category) {
        return dsts.filter!(e => e.category == category).array;
    }

    DevSpaceType[] findByCategory(TenantId tenantId, DevSpaceTypeCategory category) {
        return filterByCategory(findByTenant(tenantId), category);
    }

    void removeByCategory(TenantId tenantId, DevSpaceTypeCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }

}
///
unittest {
    mixin(ShowTest!("Running DevSpaceTypeRepository tests..."));

    void testCountByCategory() {
        auto tenantId = TenantId("tenant1");
        auto repo = new DevSpaceTypeRepository();

        // Create test entities
        auto entity1 = DevSpaceType(tenantId, DevSpaceTypeId("dst1"));
        entity1.name = "DevSpaceType 1";
        entity1.category = DevSpaceTypeCategory.predefined;
        
        auto entity2 = DevSpaceType(tenantId, DevSpaceTypeId("dst2"));
        entity2.name = "DevSpaceType 2";
        entity2.category = DevSpaceTypeCategory.custom;

        auto entity3 = DevSpaceType(tenantId, DevSpaceTypeId("dst3"));
        entity3.name = "DevSpaceType 3";
        entity3.category = DevSpaceTypeCategory.predefined;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test countByCategory
        assert(repo.countByCategory(tenantId, DevSpaceTypeCategory.predefined) == 2);
        assert(repo.countByCategory(tenantId, DevSpaceTypeCategory.custom) == 1);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testFindByCategory() {
        auto tenantId = TenantId("tenant1");
        auto repo = new DevSpaceTypeRepository();

        // Create test entities
        auto entity1 = DevSpaceType(tenantId, DevSpaceTypeId("dst1"));
        entity1.name = "DevSpaceType 1";
        entity1.category = DevSpaceTypeCategory.predefined;

        auto entity2 = DevSpaceType(tenantId, DevSpaceTypeId("dst2"));
        entity2.name = "DevSpaceType 2";
        entity2.category = DevSpaceTypeCategory.custom;

        auto entity3 = DevSpaceType(tenantId, DevSpaceTypeId("dst3"));
        entity3.name = "DevSpaceType 3";
        entity3.category = DevSpaceTypeCategory.predefined;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test findByCategory
        auto devTypes = repo.findByCategory(tenantId, DevSpaceTypeCategory.predefined);
        assert(devTypes.length == 2);
        assert(devTypes.canFind!(e => e.id == entity1.id));
        assert(devTypes.canFind!(e => e.id == entity3.id));

        auto testTypes = repo.findByCategory(tenantId, DevSpaceTypeCategory.custom);
        assert(testTypes.length == 1);
        assert(testTypes[0].id == entity2.id);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testRemoveByCategory() {
        auto tenantId = TenantId("tenant1");
        auto repo = new DevSpaceTypeRepository();

        // Create test entities
        auto entity1 = DevSpaceType(tenantId, DevSpaceTypeId("dst1"));
        entity1.name = "DevSpaceType 1";
        entity1.category = DevSpaceTypeCategory.predefined;

        auto entity2 = DevSpaceType(tenantId, DevSpaceTypeId("dst2"));
        entity2.name = "DevSpaceType 2";
        entity2.category = DevSpaceTypeCategory.custom;

        auto entity3 = DevSpaceType(tenantId, DevSpaceTypeId("dst3"));
        entity3.name = "DevSpaceType 3";
        entity3.category = DevSpaceTypeCategory.predefined;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test removeByCategory
        repo.removeByCategory(tenantId, DevSpaceTypeCategory.predefined);
        assert(repo.countByCategory(tenantId, DevSpaceTypeCategory.predefined) == 0);
        assert(repo.countByCategory(tenantId, DevSpaceTypeCategory.custom) == 1);

        // Clean up
        repo.remove(entity2);
    }

    void runAllTests() {
        testCountByCategory();
        testFindByCategory();
        testRemoveByCategory();
    }

    runAllTests();
}
