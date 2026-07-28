/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.infrastructure.persistence.repositories.platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class PlatformRepository : TenantRepository!(Platform, PlatformId), IPlatformRepository {
    
    size_t countByType(TenantId tenantId, PlatformType type) {
        return this.findByType(tenantId, type).length;
    }
    Platform[] filterByType(Platform[] platforms, PlatformType type) {
        return platforms.filter!(p => p.type == type).array;
    }
    Platform[] findByType(TenantId tenantId, PlatformType type) {
        return this.filterByType(this.findByTenant(tenantId), type);
    }
    void removeByType(TenantId tenantId, PlatformType type) {
        this.findByType(tenantId, type).each!(p => this.remove(p));
    }

    size_t countByStatus(TenantId tenantId, PlatformStatus status) {
        return this.findByStatus(tenantId, status).length;
    }
    Platform[] filterByStatus(Platform[] platforms, PlatformStatus status) {
        return platforms.filter!(p => p.status == status).array;
    }
    Platform[] findByStatus(TenantId tenantId, PlatformStatus status) {
        return this.filterByStatus(this.findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, PlatformStatus status) {
        this.findByStatus(tenantId, status).each!(p => this.remove(p));
    }
    
}

///
unittest {
    assert(tenantRepositoryTest(new PlatformRepository()));
}
