/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.broker_services;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

class MemoryBrokerServiceRepository : TenantRepository!(BrokerService, BrokerServiceId), IBrokerServiceRepository {

    size_t countByStatus(TenantId tenantId, BrokerServiceStatus status) {
        return findByStatus(tenantId, status).length;
    }
    BrokerService[] filterByStatus(BrokerService[] services, BrokerServiceStatus status) {
        return services.filter!(e => e.status == status).array;
    }    
    BrokerService[] findByStatus(TenantId tenantId, BrokerServiceStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, BrokerServiceStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByCloudProvider(TenantId tenantId, CloudProvider provider) {
        return findByCloudProvider(tenantId, provider).length;
    }

    BrokerService[] filterByCloudProvider(BrokerService[] services, CloudProvider provider) {
        return services.filter!(e => e.cloudProvider == provider).array;
    }

    BrokerService[] findByCloudProvider(TenantId tenantId, CloudProvider provider) {
        return filterByCloudProvider(findByTenant(tenantId), provider);
    }

    void removeByCloudProvider(TenantId tenantId, CloudProvider provider) {
        findByCloudProvider(tenantId, provider).each!(e => remove(e));
    }
}

unittest {
    auto repo = new MemoryBrokerServiceRepository();
    auto tenantId = TenantId("test-tenant");

    // Create sample services
    BrokerService s1;
    s1.id = BrokerServiceId("s1");
    s1.tenantId = tenantId;
    s1.status = BrokerServiceStatus.running;
    s1.cloudProvider = CloudProvider.aws;
    repo.save(s1);

    BrokerService s2;
    s2.id = BrokerServiceId("s2");
    s2.tenantId = tenantId;
    s2.status = BrokerServiceStatus.provisioning;
    s2.cloudProvider = CloudProvider.azure;
    repo.save(s2);

    BrokerService s3;
    s3.id = BrokerServiceId("s3");
    s3.tenantId = tenantId;
    s3.status = BrokerServiceStatus.running;
    s3.cloudProvider = CloudProvider.aws;
    repo.save(s3);

    // Test status methods
    assert(repo.countByStatus(tenantId, BrokerServiceStatus.running) == 2);
    assert(repo.countByStatus(tenantId, BrokerServiceStatus.provisioning) == 1);
    assert(repo.findByStatus(tenantId, BrokerServiceStatus.running).length == 2);

    // Test cloud provider methods
    assert(repo.countByCloudProvider(tenantId, CloudProvider.aws) == 2);
    assert(repo.countByCloudProvider(tenantId, CloudProvider.azure) == 1);
    assert(repo.findByCloudProvider(tenantId, CloudProvider.aws).length == 2);

    // Test removeByStatus
    repo.removeByStatus(tenantId, BrokerServiceStatus.provisioning);
    assert(repo.countByStatus(tenantId, BrokerServiceStatus.provisioning) == 0);
    assert(repo.findByTenant(tenantId).length == 2);

    // Test removeByCloudProvider
    repo.removeByCloudProvider(tenantId, CloudProvider.aws);
    assert(repo.countByCloudProvider(tenantId, CloudProvider.aws) == 0);
    
    // Final check for the tenant
    assert(repo.findByTenant(tenantId).length == 0);
}
