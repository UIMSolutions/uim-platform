/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCommandRepository : CommandRepository {
    private Command[] store;

    bool existsById(CommandId id) {
        return store.any!(e => e.id == id);
    }

    Command findById(CommandId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Command.init;
    }

    Command[] findAll() { return store; }

    Command[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Command[] findByCatalog(CatalogId catalogId) {
        return store.filter!(e => e.catalogId == catalogId).array;
    }

    Command[] findByStatus(CommandStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(Command command) { store ~= command; }

    void update(Command command) {
        foreach (ref e; store)
            if (e.id == command.id) { e = command; return; }
    }

    void remove(CommandId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
