/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.infrastructure.persistence.memory.programs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// In-memory implementation of AbapProgramRepository (driven adapter).
class MemoryAbapProgramRepository : AbapProgramRepository {
    private AbapProgram[string] _store; // key: tenantId ~ "|" ~ id

    private string key(string tenantId, ProgramId id) const {
        return tenantId ~ "|" ~ id;
    }

    AbapProgram findById(string tenantId, ProgramId id) {
        auto k = key(tenantId, id);
        if (auto p = k in _store) return *p;
        return AbapProgram.init;
    }

    AbapProgram[] findByTenant(string tenantId) {
        AbapProgram[] result;
        foreach (k, v; _store)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    void save(AbapProgram program) {
        _store[key(program.tenantId, program.id)] = program;
    }

    void update(AbapProgram program) {
        _store[key(program.tenantId, program.id)] = program;
    }

    void remove(AbapProgram program) {
        _store.remove(key(program.tenantId, program.id));
    }

    size_t countByTenant(string tenantId) {
        size_t n = 0;
        foreach (v; _store)
            if (v.tenantId == tenantId) n++;
        return n;
    }
}
