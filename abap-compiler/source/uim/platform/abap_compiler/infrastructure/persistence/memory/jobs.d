/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.infrastructure.persistence.memory.jobs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// In-memory implementation of CompilationJobRepository (driven adapter).
class MemoryCompilationJobRepository : CompilationJobRepository {
    private CompilationJob[string] _store; // key: tenantId ~ "|" ~ id

    private string key(string tenantId, CompilationJobId id) const {
        return tenantId ~ "|" ~ id;
    }

    CompilationJob findById(string tenantId, CompilationJobId id) {
        auto k = key(tenantId, id);
        if (auto j = k in _store) return *j;
        return CompilationJob.init;
    }

    CompilationJob[] findByProgram(string tenantId, ProgramId pid) {
        CompilationJob[] result;
        foreach (v; _store)
            if (v.tenantId == tenantId && v.programId == pid) result ~= v;
        return result;
    }

    CompilationJob[] findByTenant(string tenantId) {
        CompilationJob[] result;
        foreach (v; _store)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    void save(CompilationJob job) {
        _store[key(job.tenantId, job.id)] = job;
    }

    void update(CompilationJob job) {
        _store[key(job.tenantId, job.id)] = job;
    }

    void remove(CompilationJob job) {
        _store.remove(key(job.tenantId, job.id));
    }

    size_t countByTenant(string tenantId) {
        size_t n = 0;
        foreach (v; _store)
            if (v.tenantId == tenantId) n++;
        return n;
    }
}
