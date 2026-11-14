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

    void testCountByScope(IExtensionRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto extension1 = Extension(tenantId, ExtensionId("ext1"));
        extension1.name = "Extension 1";
        extension1.scope_ = ExtensionScope.thirdParty;
        auto extension2 = Extension(tenantId, ExtensionId("ext2"));
        extension2.name = "Extension 2";
        extension2.scope_ = ExtensionScope.predefined;
        auto extension3 = Extension(tenantId, ExtensionId("ext3"));
        extension3.name = "Extension 3";
        extension3.scope_ = ExtensionScope.predefined;

        // Add entities to the repository
        repo.save(extension1);
        repo.save(extension2);
        repo.save(extension3);

        // Test countByScope
        assert(repo.countByScope(tenantId, ExtensionScope.thirdParty) == 1);
        assert(repo.countByScope(tenantId, ExtensionScope.predefined) == 2);

        // Clean up
        repo.remove(extension1);
        repo.remove(extension2);
        repo.remove(extension3);
    }

    void testFindByScope(IExtensionRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto extension1 = Extension(tenantId, ExtensionId("ext1"));
        extension1.name = "Extension 1";
        extension1.scope_ = ExtensionScope.thirdParty;
        auto extension2 = Extension(tenantId, ExtensionId("ext2"));
        extension2.name = "Extension 2";
        extension2.scope_ = ExtensionScope.predefined;
        auto extension3 = Extension(tenantId, ExtensionId("ext3"));
        extension3.name = "Extension 3";
        extension3.scope_ = ExtensionScope.thirdParty;

        // Add entities to the repository
        repo.save(extension1);
        repo.save(extension2);
        repo.save(extension3);

        // Test findByScope
        auto globalExtensions = repo.findByScope(tenantId, ExtensionScope.thirdParty);
        assert(globalExtensions.length == 2);
        assert(globalExtensions.canFind!(e => e.id == extension1.id));
        assert(globalExtensions.canFind!(e => e.id == extension3.id));

        auto localExtensions = repo.findByScope(tenantId, ExtensionScope.predefined);
        assert(localExtensions.length == 1);
        assert(localExtensions[0].id == extension2.id);

        // Clean up
        repo.remove(extension1);
        repo.remove(extension2);
        repo.remove(extension3);
    }

    void testRemoveByScope(IExtensionRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto extension1 = Extension(tenantId, ExtensionId("ext1"));
        extension1.name = "Extension 1";
        extension1.scope_ = ExtensionScope.thirdParty;
        auto extension2 = Extension(tenantId, ExtensionId("ext2"));
        extension2.name = "Extension 2";
        extension2.scope_ = ExtensionScope.predefined;
        auto extension3 = Extension(tenantId, ExtensionId("ext3"));
        extension3.name = "Extension 3";
        extension3.scope_ = ExtensionScope.thirdParty;

        // Add entities to the repository
        repo.save(extension1);
        repo.save(extension2);
        repo.save(extension3);

        // Test removeByScope
        repo.removeByScope(tenantId, ExtensionScope.thirdParty);
        assert(!repo.exists(extension1));
        assert(!repo.exists(extension3));
        assert(repo.exists(extension2));

        // Clean up
        repo.remove(extension2);
    }

    void testCountByStatus(IExtensionRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto extension1 = Extension(tenantId, ExtensionId("ext1"));
        extension1.name = "Extension 1";
        extension1.scope_ = ExtensionScope.thirdParty;
        extension1.status = ExtensionStatus.active;
        auto extension2 = Extension(tenantId, ExtensionId("ext2"));
        extension2.name = "Extension 2";
        extension2.scope_ = ExtensionScope.predefined;
        extension2.status = ExtensionStatus.inactive;
        auto extension3 = Extension(tenantId, ExtensionId("ext3"));
        extension3.name = "Extension 3";
        extension3.scope_ = ExtensionScope.thirdParty;
        extension3.status = ExtensionStatus.active;

        // Add entities to the repository
        repo.save(extension1);
        repo.save(extension2);
        repo.save(extension3);

        // Test countByStatus
        assert(repo.countByStatus(tenantId, ExtensionStatus.active) == 2);
        assert(repo.countByStatus(tenantId, ExtensionStatus.inactive) == 1);

        // Clean up
        repo.remove(extension1);
        repo.remove(extension2);
        repo.remove(extension3);
    }

    void testFindByStatus(IExtensionRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto extension1 = Extension(tenantId, ExtensionId("ext1"));
        extension1.name = "Extension 1";
        extension1.scope_ = ExtensionScope.thirdParty;
        extension1.status = ExtensionStatus.active;
        auto extension2 = Extension(tenantId, ExtensionId("ext2"));
        extension2.name = "Extension 2";
        extension2.scope_ = ExtensionScope.predefined;
        extension2.status = ExtensionStatus.inactive;
        auto extension3 = Extension(tenantId, ExtensionId("ext3"));
        extension3.name = "Extension 3";
        extension3.scope_ = ExtensionScope.thirdParty;
        extension3.status = ExtensionStatus.active;

        // Add entities to the repository
        repo.save(extension1);
        repo.save(extension2);
        repo.save(extension3);

        // Test findByStatus
        auto activeExtensions = repo.findByStatus(tenantId, ExtensionStatus.active);
        assert(activeExtensions.length == 2);
        assert(activeExtensions.canFind!(e => e.id == extension1.id));
        assert(activeExtensions.canFind!(e => e.id == extension3.id));

        auto inactiveExtensions = repo.findByStatus(tenantId, ExtensionStatus.inactive);
        assert(inactiveExtensions.length == 1);
        assert(inactiveExtensions[0].id == extension2.id);

        // Clean up
        repo.remove(extension1);
        repo.remove(extension2);
        repo.remove(extension3);
    }

    void testRemoveByStatus(IExtensionRepository repo) {
        auto tenantId = TenantId("tenant1");

        // Create test entities
        auto extension1 = Extension(tenantId, ExtensionId("ext1"));
        extension1.name = "Extension 1";
        extension1.description = "Description for Extension 1";
        extension1.scope_ = ExtensionScope.thirdParty;
        extension1.status = ExtensionStatus.active;
        
        auto extension2 = Extension(tenantId, ExtensionId("ext2"));
        extension2.name = "Extension 2";
        extension2.description = "Description for Extension 2";
        extension2.scope_ = ExtensionScope.predefined;
        extension2.status = ExtensionStatus.inactive;

        auto extension3 = Extension(tenantId, ExtensionId("ext3"));
        extension3.name = "Extension 3";
        extension3.description = "Description for Extension 3";
        extension3.scope_ = ExtensionScope.thirdParty;
        extension3.status = ExtensionStatus.active;

        // Add entities to the repository
        repo.save(extension1);
        repo.save(extension2);
        repo.save(extension3);

        // Test removeByStatus
        repo.removeByStatus(tenantId, ExtensionStatus.active);
        assert(!repo.exists(extension1));
        assert(!repo.exists(extension3));
        assert(repo.exists(extension2));

        // Clean up
        repo.remove(extension2);
    }

    void runAllTests() {
        testCountByScope(new ExtensionRepository());
        testFindByScope(new ExtensionRepository());
        testRemoveByScope(new ExtensionRepository());
        testCountByStatus(new ExtensionRepository());
        testFindByStatus(new ExtensionRepository());
        testRemoveByStatus(new ExtensionRepository());
    }

    runAllTests();
}
