/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface CommandRepository : ITenantRepository!(Command, CommandId) {

    size_t countByCatalog(CatalogId catalogId);
    Command[] findByCatalog(CatalogId catalogId);
    void removeByCatalog(CatalogId catalogId);

    size_t countByStatus(CommandStatus status);
    Command[] findByStatus(CommandStatus status);
    void removeByStatus(CommandStatus status);

}
