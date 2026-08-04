/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.extensions;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository for managing Extension entities in a multi-tenant environment.
class ExtensionRepository : TenantRepository!(Extension, ExtensionId), IExtensionRepository {

    // #region ByScope
    size_t countByScope(TenantId tenantId, ExtensionScope scope_) {
        return findByScope(tenantId, scope_).length;
    }

    Extension[] filterByScope(Extension[] extensions, ExtensionScope scope_) {
        return extensions.filter!(e => e.scope_ == scope_).array;
    }

    Extension[] findByScope(TenantId tenantId, ExtensionScope scope_) {
        return filterByScope(findByTenant(tenantId), scope_);
    }

    void removeByScope(TenantId tenantId, ExtensionScope scope_) {
        findByScope(tenantId, scope_).each!(e => remove(e));
    }
    // #endregion ByScope

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, ExtensionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Extension[] filterByStatus(Extension[] extensions, ExtensionStatus status) {
        return extensions.filter!(e => e.status == status).array;
    }

    Extension[] findByStatus(TenantId tenantId, ExtensionStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ExtensionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
///
unittest {
    mixin(ShowTest!("Running ExtensionRepository tests..."));

    void testCountByScope() {
        auto tenantId = TenantId("tenant1");
        auto repo = new ExtensionRepository();

        // Create test entities
        auto entity1 = Extension(ExtensionId("ext1"), tenantId, "Extension 1", ExtensionScope
                .thirdParty);
        auto entity2 = Extension(ExtensionId("ext2"), tenantId, "Extension 2", ExtensionScope.predefined);
        auto entity3 = Extension(ExtensionId("ext3"), tenantId, "Extension 3", ExtensionScope
                .thirdParty);

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test countByScope
        assert(repo.countByScope(tenantId, ExtensionScope.thirdParty) == 2);
        assert(repo.countByScope(tenantId, ExtensionScope.predefined) == 1);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testFindByScope() {
        auto tenantId = TenantId("tenant1");
        auto repo = new ExtensionRepository();

        // Create test entities
        auto entity1 = Extension(ExtensionId("ext1"), tenantId, "Extension 1", ExtensionScope
                .thirdParty);
        auto entity2 = Extension(ExtensionId("ext2"), tenantId, "Extension 2", ExtensionScope.predefined);
        auto entity3 = Extension(ExtensionId("ext3"), tenantId, "Extension 3", ExtensionScope
                .thirdParty);

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test findByScope
        auto globalExtensions = repo.findByScope(tenantId, ExtensionScope.thirdParty);
        assert(globalExtensions.length == 2);
        assert(globalExtensions.canFind!(e => e.id == entity1.id));
        assert(globalExtensions.canFind!(e => e.id == entity3.id));

        auto localExtensions = repo.findByScope(tenantId, ExtensionScope.predefined);
        assert(localExtensions.length == 1);
        assert(localExtensions[0].id == entity2.id);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testRemoveByScope() {
        auto tenantId = TenantId("tenant1");
        auto repo = new ExtensionRepository();

        // Create test entities
        auto entity1 = Extension(ExtensionId("ext1"), tenantId, "Extension 1", ExtensionScope
                .thirdParty);
        auto entity2 = Extension(ExtensionId("ext2"), tenantId, "Extension 2", ExtensionScope.predefined);
        auto entity3 = Extension(ExtensionId("ext3"), tenantId, "Extension 3", ExtensionScope
                .thirdParty);

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test removeByScope
        repo.removeByScope(tenantId, ExtensionScope.thirdParty);
        assert(!repo.exists(entity1));
        assert(!repo.exists(entity3));
        assert(repo.exists(entity2));

        // Clean up
        repo.remove(entity2);
    }

    void testCountByStatus() {
        auto tenantId = TenantId("tenant1");
        auto repo = new ExtensionRepository();

        // Create test entities
        auto entity1 = Extension(ExtensionId("ext1"), tenantId, "Extension 1", ExtensionScope
                .thirdParty);
        entity1.status = ExtensionStatus.active;
        auto entity2 = Extension(ExtensionId("ext2"), tenantId, "Extension 2", ExtensionScope.predefined);
        entity2.status = ExtensionStatus.inactive;
        auto entity3 = Extension(ExtensionId("ext3"), tenantId, "Extension 3", ExtensionScope.thirdParty);
        entity3.status = ExtensionStatus.active;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test countByStatus
        assert(repo.countByStatus(tenantId, ExtensionStatus.active) == 2);
        assert(repo.countByStatus(tenantId, ExtensionStatus.inactive) == 1);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testFindByStatus() {
        auto tenantId = TenantId("tenant1");
        auto repo = new ExtensionRepository();

        // Create test entities
        auto entity1 = Extension(ExtensionId("ext1"), tenantId, "Extension 1", ExtensionScope
                .thirdParty);
        entity1.status = ExtensionStatus.active;
        auto entity2 = Extension(ExtensionId("ext2"), tenantId, "Extension 2", ExtensionScope.predefined);
        entity2.status = ExtensionStatus.inactive;
        auto entity3 = Extension(ExtensionId("ext3"), tenantId, "Extension 3", ExtensionScope
                .thirdParty);
        entity3.status = ExtensionStatus.active;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test findByStatus
        auto activeExtensions = repo.findByStatus(tenantId, ExtensionStatus.active);
        assert(activeExtensions.length == 2);
        assert(activeExtensions.canFind!(e => e.id == entity1.id));
        assert(activeExtensions.canFind!(e => e.id == entity3.id));

        auto inactiveExtensions = repo.findByStatus(tenantId, ExtensionStatus.inactive);
        assert(inactiveExtensions.length == 1);
        assert(inactiveExtensions[0].id == entity2.id);

        // Clean up
        repo.remove(entity1);
        repo.remove(entity2);
        repo.remove(entity3);
    }

    void testRemoveByStatus() {
        auto tenantId = TenantId("tenant1");
        auto repo = new ExtensionRepository();

        // Create test entities
        auto entity1 = Extension(ExtensionId("ext1"), tenantId, "Extension 1", ExtensionScope
                .thirdParty);
        entity1.status = ExtensionStatus.active;
        auto entity2 = Extension(ExtensionId("ext2"), tenantId, "Extension 2", ExtensionScope.predefined);
        entity2.status = ExtensionStatus.inactive;
        auto entity3 = Extension(ExtensionId("ext3"), tenantId, "Extension 3", ExtensionScope
                .thirdParty);
        entity3.status = ExtensionStatus.active;

        // Add entities to the repository
        repo.save(entity1);
        repo.save(entity2);
        repo.save(entity3);

        // Test removeByStatus
        repo.removeByStatus(tenantId, ExtensionStatus.active);
        assert(!repo.exists(entity1));
        assert(!repo.exists(entity3));
        assert(repo.exists(entity2));

        // Clean up
        repo.remove(entity2);
    }

    void runAllTests() {
        testCountByScope();
        testFindByScope();
        testRemoveByScope();
        testCountByStatus();
        testFindByStatus();
        testRemoveByStatus();
    }

    runAllTests();
}
