/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.mongodb_.service_instance_repo;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

class MongoDbServiceInstanceRepository : ServiceInstanceRepository {
    private MemoryServiceInstanceRepository fallback;
    private string connectionUri;
    private string dbName;

    this(string connectionUri, string dbName) {
        this.connectionUri = connectionUri;
        this.dbName        = dbName;
        this.fallback      = new MemoryServiceInstanceRepository();
        // TODO: connect and wire mongo collection
    }

    void save(ServiceInstance inst)   { fallback.save(inst);   }
    void update(ServiceInstance inst) { fallback.update(inst); }
    void remove(ServiceInstance inst) { fallback.remove(inst); }

    ServiceInstance findById(TenantId tenantId, ServiceInstanceId id) {
        return fallback.findById(tenantId, id);
    }

    ServiceInstance findByName(TenantId tenantId, string name) {
        return fallback.findByName(tenantId, name);
    }

    ServiceInstance[] findByTenant(TenantId tenantId) {
        return fallback.findByTenant(tenantId);
    }

    size_t countByTenant(TenantId tenantId) {
        return fallback.count(tenantId);
    }
}
