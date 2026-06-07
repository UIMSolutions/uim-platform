/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.extensions;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

interface ExtensionRepository : ITenantRepository!(Extension, ExtensionId) {
    
    size_t countByScope(TenantId tenantId, ExtensionScope scope_);
    Extension[] findByScope(TenantId tenantId, ExtensionScope scope_);
    void removeByScope(TenantId tenantId, ExtensionScope scope_);
    
    size_t countByStatus(TenantId tenantId, ExtensionStatus status);
    Extension[] findByStatus(TenantId tenantId, ExtensionStatus status);
    void removeByStatus(TenantId tenantId, ExtensionStatus status);
    
}
