/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.memory.configurations;

import uim.platform.postgres;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryConfigurationRepository
    : TenantRepository!(Configuration, ConfigurationId)
    , ConfigurationRepository
{
    override Configuration findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : Configuration.init;
    }
}
