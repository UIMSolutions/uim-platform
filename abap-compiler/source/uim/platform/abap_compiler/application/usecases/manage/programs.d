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

        auto existing = repo.findById(r.tenantId, r.programId);
        if (!existing.isNull)
            return CommandResult(false, "", "Program '" ~ r.programId.toString() ~ "' already exists");

        auto program = AbapProgram.create(r.programId.toString(), r.tenantId, r.programType, r.title, r.language, r.sourceCode);
        repo.save(program);
        return CommandResult(true, program.id.toString(), "");
    }

    AbapProgram getProgram(TenantId tenantId, AbapProgramId programId) {
        return repo.findById(tenantId, programId);
    }

    AbapProgram[] listPrograms(TenantId tenantId) {
        return repo.findAll().filter!(p => p.tenantId.value == tenantId.value).array;
    }

    CommandResult updateProgram(UpdateProgramRequest r) {
        auto existing = repo.findById(r.tenantId, r.programId);
        if (existing.isNull)
            return CommandResult(false, "", "Program '" ~ r.programId.value ~ "' not found");

        import core.time : MonoTime;
        existing.title      = r.title;
        existing.language   = r.language;
        existing.sourceCode = r.sourceCode;
        existing.updatedAt  = MonoTime.currTime.ticks;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteProgram(TenantId tenantId, AbapProgramId programId) {
        auto existing = repo.findById(tenantId, programId);
        if (existing.isNull)
            return CommandResult(false, "", "Program '" ~ programId.value ~ "' not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }

    size_t countPrograms(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }
}
