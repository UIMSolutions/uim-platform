/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.branding_configs;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

class MemoryBrandingConfigRepository : TentRepository!(BrandingConfig, BrandingConfigId), BrandingConfigRepository {
    
    bool existsByName(TenantId tenantId, string name) {
        return findByName(tenantId, name).id != BrandingConfigId.init;
    }
    BrandingConfig findByName(TenantId tenantId, string name) {
        foreach (e; findByTenant(tenantId))
            if (e.name == name) return e;
        return BrandingConfig.init;
    }
    void removeByName(TenantId tenantId, string name) {
        foreach (e; findByTenant(tenantId))
            if (e.name == name) {
                remove(e);
                return;
            }   
    }

}
