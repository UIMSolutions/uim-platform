/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.repositories.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ICommandRepository : ITenantRepository!(PilotCommand, CommandId) {

    size_t countByCatalog(TenantId tenantId, CatalogId catalogId);
    PilotCommand[] findByCatalog(TenantId tenantId, CatalogId catalogId);
    void removeByCatalog(TenantId tenantId, CatalogId catalogId);

    size_t countByStatus(TenantId tenantId, CommandStatus status);
    PilotCommand[] findByStatus(TenantId tenantId, CommandStatus status);
    void removeByStatus(TenantId tenantId, CommandStatus status);

}
