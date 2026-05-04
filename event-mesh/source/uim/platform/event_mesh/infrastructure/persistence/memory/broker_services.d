/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.broker_services;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryBrokerServiceRepository : TenantRepository!(BrokerService, BrokerServiceId), BrokerServiceRepository {

    size_t countByStatus(BrokerServiceStatus status) {
        return findByStatus(status).length;
    }
    BrokerService[] filterByStatus(BrokerService[] services, BrokerServiceStatus status) {
        return services.filter!(e => e.status == status).array;
    }    
    BrokerService[] findByStatus(BrokerServiceStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(BrokerServiceStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

    size_t countByCloudProvider(CloudProvider provider) {
        return findByCloudProvider(provider).length;
    }

    BrokerService[] filterByCloudProvider(BrokerService[] services, CloudProvider provider) {
        return services.filter!(e => e.cloudProvider == provider).array;
    }

    BrokerService[] findByCloudProvider(CloudProvider provider) {
        return findAll().filter!(e => e.cloudProvider == provider).array;
    }

    void removeByCloudProvider(CloudProvider provider) {
        findByCloudProvider(provider).each!(e => remove(e));
    }

}
