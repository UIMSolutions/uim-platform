/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.branding_configs;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface BrandingConfigRepository {
    bool existsById(BrandingConfigId id);
    BrandingConfig findById(BrandingConfigId id);
    BrandingConfig[] findAll();
    BrandingConfig[] findByTenant(TenantId tenantId);
    void save(BrandingConfig entity);
    void update(BrandingConfig entity);
    void remove(BrandingConfigId id);
}
