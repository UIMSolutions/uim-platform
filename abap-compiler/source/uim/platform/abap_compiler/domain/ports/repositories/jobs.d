/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.repositories.jobs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Primary port: repository contract for compilation jobs.
interface CompilationJobRepository {
    CompilationJob    findById(string tenantId, CompilationJobId id);
    CompilationJob[]  findByProgram(string tenantId, ProgramId pid);
    CompilationJob[]  findByTenant(string tenantId);
    void              save(CompilationJob job);
    void              update(CompilationJob job);
    void              remove(CompilationJob job);
    size_t            countByTenant(string tenantId);
}
