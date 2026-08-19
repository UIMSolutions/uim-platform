/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.repositories.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class CommandRepository : TenantRepository!(PilotCommand, CommandId), ICommandRepository {

    // #region ByCatalog
    size_t countByCatalog(TenantId tenantId, CatalogId catalogId) {
        return findByCatalog(tenantId, catalogId).length;
    }

    PilotCommand[] findByCatalog(TenantId tenantId, CatalogId catalogId) {
        return filterByCatalog(findByTenant(tenantId), catalogId);
    }

    PilotCommand[] filterByCatalog(PilotCommand[] commands, CatalogId catalogId) {
        return commands.filter!(e => e.catalogId == catalogId).array;
    }

    void removeByCatalog(TenantId tenantId, CatalogId catalogId) {
        findByCatalog(tenantId, catalogId).each!(e => remove(e));
    }
    // #endregion ByCatalog

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, CommandStatus status) {
        return findByStatus(tenantId, status).length;
    }

    PilotCommand[] findByStatus(TenantId tenantId, CommandStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    PilotCommand[] filterByStatus(PilotCommand[] commands, CommandStatus status) {
        return commands.filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, CommandStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
