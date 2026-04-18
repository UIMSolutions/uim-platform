/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface CommandRepository {
    bool existsById(CommandId id);
    Command findById(CommandId id);

    Command[] findAll();
    Command[] findByTenant(TenantId tenantId);
    Command[] findByCatalog(CatalogId catalogId);
    Command[] findByStatus(CommandStatus status);

    void save(Command command);
    void update(Command command);
    void remove(CommandId id);
}
