/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.application.usecases.manage.programs;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Application use case: CRUD management of ABAP source programs in the repository.
class ManageProgramsUseCase {
    private AbapProgramRepository repo;

    this(AbapProgramRepository repo) {
        this.repo = repo;
    }

    CommandResult createProgram(CreateProgramRequest r) {
        if (r.programId.isNull())
            return CommandResult(false, "", "Program ID is required");

        if (r.tenantId.isNull())
            return CommandResult(false, "", "Tenant ID is required");

        if (repo.existsById(r.tenantId, r.programId))
             return CommandResult(false, "", "Program '" ~ r.programId.toString() ~ "' already exists");

        auto program = AbapProgram(r.tenantId, r.programId);
        program.programType = r.programType.toProgramType;
        program.title = r.title;
        program.language = r.language;
        program.sourceCode = r.sourceCode;

        repo.save(program);
        return CommandResult(true, program.id.toString(), "");
    }

    AbapProgram getProgram(TenantId tenantId, AbapProgramId programId) {
        return repo.findById(tenantId, programId);
    }

    AbapProgram[] listPrograms(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateProgram(UpdateProgramRequest r) {
        auto program = repo.find(r.tenantId, r.programId);
        if (program.isNull)
            return CommandResult(false, "", "Program '" ~ r.programId.value ~ "' not found");
        
        program.title      = r.title;
        program.language   = r.language;
        program.sourceCode = r.sourceCode;
        program.updatedAt  = MonoTime.currTime.ticks;
        repo.update(program);
        return CommandResult(true, program.id.value, "");
    }

    CommandResult deleteProgram(TenantId tenantId, AbapProgramId programId) {
        auto program = repo.findById(tenantId, programId);
        if (program.isNull)
            return CommandResult(false, "", "Program '" ~ programId.value ~ "' not found");

        repo.remove(program);
        return CommandResult(true, program.id.value, "");
    }

    size_t countPrograms(TenantId tenantId) {
        return repo.count(tenantId);
    }
}
