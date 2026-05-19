/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.repositories.database_extensions;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

interface DatabaseExtensionRepository : ITenantRepository!(DatabaseExtension, DatabaseExtensionId) {
    DatabaseExtension[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    DatabaseExtension[] findByStatus(TenantId tenantId, ExtensionStatus status);
    bool extensionExists(TenantId tenantId, ServiceInstanceId instanceId, string extensionName);
}
