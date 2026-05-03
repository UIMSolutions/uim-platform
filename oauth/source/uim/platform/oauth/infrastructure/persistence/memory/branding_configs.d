/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.branding_configs;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryBrandingConfigRepository : TenantRepository!(BrandingConfig, BrandingConfigId), BrandingConfigRepository {

    // TODO: Implement query methods for clientId and other relevant fields as needed.
}
