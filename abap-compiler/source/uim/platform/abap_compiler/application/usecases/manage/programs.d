/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.application.usecases.manage.programs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Application use case: CRUD management of ABAP source programs in the repository.
class ManageProgramsUseCase {
    private AbapProgramRepository repo;

    this(AbapProgramRepository repo) {
        this.repo = repo;
    }

    CommandResult createProgram(CreateProgramRequest r) {
        if (r.id.length == 0)
            return CommandResult(false, "", "Program ID is required");
        if (r.tenantId.length == 0)
            return CommandResult(false, "", "Tenant ID is required");

        auto existing = repo.findById(r.tenantId, r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Program '" ~ r.id ~ "' already exists");

        auto program = AbapProgram.create(r.id, r.tenantId, r.programType, r.title, r.language, r.sourceCode);
        repo.save(program);
        return CommandResult(true, program.id, "");
    }

    AbapProgram getProgram(TenantId tenantId, ProgramId id) {
        return repo.findById(tenantId, id);
    }

    AbapProgram[] listPrograms(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateProgram(UpdateProgramRequest r) {
        auto existing = repo.findById(r.tenantId, r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Program '" ~ r.id ~ "' not found");

        import core.time : MonoTime;
        existing.title      = r.title;
        existing.language   = r.language;
        existing.sourceCode = r.sourceCode;
        existing.updatedAt  = MonoTime.currTime.ticks;
        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult deleteProgram(TenantId tenantId, ProgramId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Program '" ~ id ~ "' not found");

        repo.remove(existing);
        return CommandResult(true, id, "");
    }

    size_t countPrograms(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }
}
