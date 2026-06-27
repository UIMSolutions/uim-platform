/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.persistence.memory.configuration;


// import uim.platform.job_scheduling.domain.entities.configuration;
// import uim.platform.job_scheduling.domain.ports.repositories.configurations;
import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : TentRepository!(Configuration, ConfigurationId), ConfigurationRepository {
    Configuration get(TenantId tenantId) {
        auto configs = findByTenant(tenantId);
        if (configs.length > 0) {
            return configs[0];
        }
        return Configuration.init;
    }
}
