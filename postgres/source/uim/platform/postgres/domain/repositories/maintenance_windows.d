/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.repositories.maintenance_windows;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

interface MaintenanceWindowRepository : ITenantRepository!(MaintenanceWindow, MaintenanceWindowId) {
    MaintenanceWindow findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    MaintenanceWindow[] findByStatus(TenantId tenantId, MaintenanceStatus status);
}
