/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.repositories.programs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Primary port: repository contract for ABAP program source artefacts.
interface AbapProgramRepository {
    AbapProgram    findById(string tenantId, ProgramId id);
    AbapProgram[]  findByTenant(string tenantId);
    void           save(AbapProgram program);
    void           update(AbapProgram program);
    void           remove(AbapProgram program);
    size_t         countByTenant(string tenantId);
}
