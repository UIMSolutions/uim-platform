/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.repositories.jobs;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Primary port: repository contract for compilation jobs.
interface CompilationJobRepository : ITentRepository!(CompilationJob, CompilationJobId) {
 
    size_t countByProgram(TenantId tenantId, AbapProgramId pid);  
    CompilationJob[] findByProgram(TenantId tenantId, AbapProgramId pid);
    void removeByProgram(TenantId tenantId, AbapProgramId pid);
 
}
