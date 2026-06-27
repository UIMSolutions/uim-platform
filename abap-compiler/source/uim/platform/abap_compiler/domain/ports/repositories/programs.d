/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.repositories.programs;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Primary port: repository contract for ABAP program source artefacts.
interface AbapProgramRepository : ITenantRepository!(AbapProgram, AbapProgramId) {

    size_t countByProgramType(TenantId tenantId, ProgramType programType);
    AbapProgram[]  findByProgramType(TenantId tenantId, ProgramType programType);
    void removeByProgramType(TenantId tenantId, ProgramType programType);

    size_t countByLanguage(TenantId tenantId, string language);
    AbapProgram[]  findByLanguage(TenantId tenantId, string language);
    void removeByLanguage(TenantId tenantId, string language);

}
