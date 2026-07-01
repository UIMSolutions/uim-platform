/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.application.usecases.manage.jobs;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Application use case: query / manage compilation jobs.
class ManageJobsUseCase {
    private CompilationJobRepository repo;

    this(CompilationJobRepository repo) {
        this.repo = repo;
    }

    CompilationJob getJob(TenantId tenantId, CompilationJobId id) {
        return repo.findById(tenantId, id);
    }

    CompilationJob[] listJobs(TenantId tenantId) {
        return repo.findByTenant(tenantId).array;
    }

    CompilationJob[] listJobsForProgram(TenantId tenantId, AbapProgramId pid) {
        return repo.findByTenant(tenantId)
            .filter!(job => job.programId.value == pid.value)
            .array;
    }

    CommandResult deleteJob(TenantId tenantId, CompilationJobId id) {
        auto job = repo.findById(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Job '" ~ id.toString ~ "' not found");
        repo.remove(job);
        return CommandResult(true, id.toString, "");
    }
}
