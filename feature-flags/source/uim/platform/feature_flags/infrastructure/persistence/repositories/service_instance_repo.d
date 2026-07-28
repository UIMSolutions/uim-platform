/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.repositories.service_instance_repo;

import uim.platform.feature_flags;
import std.algorithm : filter;
import std.array     : array;

mixin(ShowModule!());

@safe:

class MemoryServiceInstanceRepository : ServiceInstanceRepository {
    private ServiceInstance[string] store;

    void save(ServiceInstance inst) {
        store[key(inst.tenantId, inst.id.value)] = inst;
    }

    void update(ServiceInstance inst) {
        store[key(inst.tenantId, inst.id.value)] = inst;
    }

    void remove(ServiceInstance inst) {
        store.remove(key(inst.tenantId, inst.id.value));
    }

    ServiceInstance findById(TenantId tenantId, ServiceInstanceId id) {
        auto k = key(tenantId, id.value);
        auto p = k in store;
        return p ? *p : ServiceInstance.init;
    }

    ServiceInstance findByName(TenantId tenantId, string name) {
        foreach (inst; store.values)
            if (inst.tenantId == tenantId && inst.name == name)
                return inst;
        return ServiceInstance.init;
    }

    ServiceInstance[] findByTenant(TenantId tenantId) {
        return store.values.filter!(i => i.tenantId == tenantId).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return findByTenant(tenantId).length;
    }

    private string key(TenantId tenantId, string id) const {
        return tenantId ~ ":" ~ id;
    }
}
