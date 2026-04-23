/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCommandRepository : TenantRepository!(Command, CommandId), CommandRepository {

    // #region ByCatalog
    size_t countByCatalog(CatalogId catalogId) {
        return findByCatalog(catalogId).length;
    }

    Command[] findByCatalog(CatalogId catalogId) {
        return store.filter!(e => e.catalogId == catalogId).array;
    }

    void removeByCatalog(CatalogId catalogId) {
        return findByCatalog(catalogId).each!(e => remove(e));
    }
    // #endregion ByCatalog

    // #region ByStatus
    size_t countByStatus(CommandStatus status) {
        return findByStatus(status).length;
    }

    Command[] findByStatus(CommandStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void removeByStatus(CommandStatus status) {
        return findByStatus(status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
