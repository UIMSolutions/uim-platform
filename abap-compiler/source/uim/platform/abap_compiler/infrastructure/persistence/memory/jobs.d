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
class MemoryCompilationJobRepository : TenantRepository!(CompilationJob, CompilationJobId), CompilationJobRepository {
    
    size_t countByProgram(TenantId tenantId, ProgramId pid) {
        return findByProgram(tenantId, pid).length;
    }

    CompilationJob[] filterByProgram(CompilationJob[] jobs, ProgramId pid) {
        return jobs.filter!(j => j.programId == pid).array;
    }

    CompilationJob[] findByProgram(TenantId tenantId, ProgramId pid) {
        return filterByProgram(findByTenant(tenantId), pid);
    }

    void removeByProgram(TenantId tenantId, ProgramId pid) {
        findByProgram(tenantId, pid).each!(job => remove(job));
    }

}
