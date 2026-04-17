/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.configuration;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.configuration;
// import uim.platform.job_scheduling.domain.ports.repositories.configurations;
import uim.platform.job_scheduling

mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : ConfigurationRepository {
    private Configuration[string] store; // keyed by tenantId

    bool existsByTenant(TenantId tenantId) {
        return (tenantId in store) ? true : false;
    }

    Configuration findByTenant(TenantId tenantId) {
        return existsByTenant(tenantId) ? store[tenantId] : Configuration.init;
    }

    void save(Configuration c) {
        store[c.tenantId] = c;
    }

    void update(Configuration c) {
        if (existsByTenant(c.tenantId)) {
            store[c.tenantId] = c;
        }
    }
}
