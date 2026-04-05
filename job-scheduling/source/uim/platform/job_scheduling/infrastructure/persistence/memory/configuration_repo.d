/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.configuration_repo;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.configuration;
import uim.platform.job_scheduling.domain.ports.repositories.configurations;

class MemoryConfigurationRepository : ConfigurationRepository {
    private Configuration[string] store; // keyed by tenantId

    Configuration findByTenant(TenantId tenantId) {
        if (auto c = tenantId in store)
            return *c;
        return Configuration.init;
    }

    void save(Configuration c) {
        store[c.tenantId] = c;
    }

    void update(Configuration c) {
        store[c.tenantId] = c;
    }
}
