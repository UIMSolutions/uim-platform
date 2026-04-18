/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.extensions;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface ExtensionRepository {
    bool existsById(ExtensionId id);
    Extension findById(ExtensionId id);

    Extension[] findAll();
    Extension[] findByTenant(TenantId tenantId);
    Extension[] findByScope(ExtensionScope scope_);
    Extension[] findByStatus(ExtensionStatus status);

    void save(Extension entity);
    void update(Extension entity);
    void remove(ExtensionId id);
}
