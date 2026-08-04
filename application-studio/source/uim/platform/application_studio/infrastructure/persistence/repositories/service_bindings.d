/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository interface for managing ServiceBinding entities.
class ServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {

    // #region ByDevSpace
    size_t countByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return findByDevSpace(tenantId, devSpaceId).length;
    }

    ServiceBinding[] filterByDevSpace(ServiceBinding[] bindings, DevSpaceId devSpaceId) {
        return bindings.filter!(e => e.devSpaceId == devSpaceId).array;
    }

    ServiceBinding[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return filterByDevSpace(findByTenant(tenantId), devSpaceId);
    }
    
    void removeByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        findByDevSpace(tenantId, devSpaceId).each!(e => remove(e));
    }
    // #endregion ByDevSpace

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, BindingStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ServiceBinding[] filterByStatus(ServiceBinding[] bindings, BindingStatus status) {
        return bindings.filter!(e => e.status == status).array;
    }

    ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, BindingStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
///
unittest {
    mixin(ShowTest!("Running ServiceBindingRepository tests..."));

    void testCountByDevSpace(IServiceBindingRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        auto binding1 = ServiceBinding(tenantId, ServiceBindingId("binding1"));
        binding1.devSpaceId = devSpaceId;
        binding1.status = BindingStatus.connected;

        auto binding2 = ServiceBinding(tenantId, ServiceBindingId("binding2"));
        binding2.devSpaceId = devSpaceId;
        binding2.status = BindingStatus.connected;

        auto binding3 = ServiceBinding(tenantId, ServiceBindingId("binding3"));
        binding3.devSpaceId = DevSpaceId("devspace2");
        binding3.status = BindingStatus.disconnected;

        repo.save(binding1);
        repo.save(binding2);
        repo.save(binding3);

        assert(repo.countByDevSpace(tenantId, devSpaceId) == 2);
    }

    void testFindByDevSpace(IServiceBindingRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        auto binding1 = ServiceBinding(tenantId, ServiceBindingId("binding1"));
        binding1.devSpaceId = devSpaceId;
        binding1.status = BindingStatus.connected;

        auto binding2 = ServiceBinding(tenantId, ServiceBindingId("binding2"));
        binding2.devSpaceId = devSpaceId;
        binding2.status = BindingStatus.connected;

        auto binding3 = ServiceBinding(tenantId, ServiceBindingId("binding3"));
        binding3.devSpaceId = DevSpaceId("devspace2");
        binding3.status = BindingStatus.disconnected;

        repo.save(binding1);
        repo.save(binding2);
        repo.save(binding3);

        auto foundBindings = repo.findByDevSpace(tenantId, devSpaceId);
        assert(foundBindings.length == 2);
    }

    void testRemoveByDevSpace(IServiceBindingRepository repo) {
        auto tenantId = TenantId("tenant1");
        auto devSpaceId = DevSpaceId("devspace1");

        auto binding1 = ServiceBinding(tenantId, ServiceBindingId("binding1"));
        binding1.devSpaceId = devSpaceId;
        binding1.status = BindingStatus.connected;

        auto binding2 = ServiceBinding(tenantId, ServiceBindingId("binding2"));
        binding2.devSpaceId = devSpaceId;
        binding2.status = BindingStatus.connected;

        auto binding3 = ServiceBinding(tenantId, ServiceBindingId("binding3"));
        binding3.devSpaceId = DevSpaceId("devspace2");
        binding3.status = BindingStatus.disconnected;

        repo.save(binding1);
        repo.save(binding2);
        repo.save(binding3);

        repo.removeByDevSpace(tenantId, devSpaceId);
        assert(repo.countByDevSpace(tenantId, devSpaceId) == 0);
    }

    void testCountByStatus(IServiceBindingRepository repo) {
        auto tenantId = TenantId("tenant1");

        auto binding1 = ServiceBinding(tenantId, ServiceBindingId("binding1"));
        binding1.status = BindingStatus.connected;

        auto binding2 = ServiceBinding(tenantId, ServiceBindingId("binding2"));
        binding2.status = BindingStatus.connected;

        auto binding3 = ServiceBinding(tenantId, ServiceBindingId("binding3"));
        binding3.status = BindingStatus.disconnected;

        repo.save(binding1);
        repo.save(binding2);
        repo.save(binding3);

        assert(repo.countByStatus(tenantId, BindingStatus.connected) == 2);
    }

    void testFindByStatus(IServiceBindingRepository repo) {
        auto tenantId = TenantId("tenant1");

        auto binding1 = ServiceBinding(tenantId, ServiceBindingId("binding1"));
        binding1.status = BindingStatus.connected;

        auto binding2 = ServiceBinding(tenantId, ServiceBindingId("binding2"));
        binding2.status = BindingStatus.connected;

        auto binding3 = ServiceBinding(tenantId, ServiceBindingId("binding3"));
        binding3.status = BindingStatus.disconnected;

        repo.save(binding1);
        repo.save(binding2);
        repo.save(binding3);

        auto foundBindings = repo.findByStatus(tenantId, BindingStatus.connected);
        assert(foundBindings.length == 2);
    }

    void testRemoveByStatus(IServiceBindingRepository repo) {
        auto tenantId = TenantId("tenant1");

        auto binding1 = ServiceBinding(tenantId, ServiceBindingId("binding1"));
        binding1.status = BindingStatus.connected;

        auto binding2 = ServiceBinding(tenantId, ServiceBindingId("binding2"));
        binding2.status = BindingStatus.connected;

        auto binding3 = ServiceBinding(tenantId, ServiceBindingId("binding3"));
        binding3.status = BindingStatus.disconnected;

        repo.save(binding1);
        repo.save(binding2);
        repo.save(binding3);

        repo.removeByStatus(tenantId, BindingStatus.connected);
        assert(repo.countByStatus(tenantId, BindingStatus.connected) == 0);
    }

    void runAllTests() {
        testCountByDevSpace(new ServiceBindingRepository());
        testFindByDevSpace(new ServiceBindingRepository());
        testRemoveByDevSpace(new ServiceBindingRepository());
        testCountByStatus(new ServiceBindingRepository());
        testFindByStatus(new ServiceBindingRepository());
        testRemoveByStatus(new ServiceBindingRepository());
    }

    runAllTests();
}
