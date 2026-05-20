/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.application.usecases.manage.jobs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Application use case: query / manage compilation jobs.
class ManageJobsUseCase {
    private CompilationJobRepository repo;

    this(CompilationJobRepository repo) {
        this.repo = repo;
    }

    CompilationJob   getJob(string tenantId, CompilationJobId id) {
        return repo.findById(tenantId, id);
    }

    CompilationJob[] listJobs(string tenantId) {
        return repo.findByTenant(tenantId);
    }

    CompilationJob[] listJobsForProgram(string tenantId, ProgramId pid) {
        return repo.findByProgram(tenantId, pid);
    }

    CommandResult deleteJob(string tenantId, CompilationJobId id) {
        auto job = repo.findById(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Job '" ~ id ~ "' not found");
        repo.remove(job);
        return CommandResult(true, id, "");
    }
}
