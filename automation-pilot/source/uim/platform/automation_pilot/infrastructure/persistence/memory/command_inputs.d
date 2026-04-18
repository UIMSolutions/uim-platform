/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.command_inputs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCommandInputRepository : CommandInputRepository {
    private CommandInput[] store;

    bool existsById(CommandInputId id) {
        return store.any!(e => e.id == id);
    }

    CommandInput findById(CommandInputId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return CommandInput.init;
    }

    CommandInput[] findAll() { return store; }

    CommandInput[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    CommandInput[] findByType(InputType inputType) {
        return store.filter!(e => e.inputType == inputType).array;
    }

    void save(CommandInput input) { store ~= input; }

    void update(CommandInput input) {
        foreach (ref e; store)
            if (e.id == input.id) { e = input; return; }
    }

    void remove(CommandInputId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
