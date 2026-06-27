/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.broker_services;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class BrokerServiceRepository : TentRepository!(BrokerService, BrokerServiceId), IBrokerServiceRepository {

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
