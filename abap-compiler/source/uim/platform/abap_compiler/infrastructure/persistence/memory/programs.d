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

    size_t countByProgramType(TenantId tenantId, ProgramType programType) {
        return findByProgramType(tenantId, programType).length;
    }

    AbapProgram[] filterByProgramType(AbapProgram[] programs, ProgramType programType) {
        return programs.filter!(p => p.programType == programType).array;
    }

    AbapProgram[] findByProgramType(TenantId tenantId, ProgramType programType) {
        return filterByProgramType(findByTenant(tenantId), programType);
    }

    void removeByProgramType(TenantId tenantId, ProgramType programType) {
        findByProgramType(tenantId, programType).each!(p => remove(p));
    }

    size_t countByLanguage(TenantId tenantId, string language) {
        return findByLanguage(tenantId, language).length;
    }

    AbapProgram[] filterByLanguage(AbapProgram[] programs, string language) {
        return programs.filter!(p => p.language == language).array;
    }

    AbapProgram[] findByLanguage(TenantId tenantId, string language) {
        return filterByLanguage(findByTenant(tenantId), language);
    }

    void removeByLanguage(TenantId tenantId, string language) {
        findByLanguage(tenantId, language).each!(p => remove(p));
    }
}
