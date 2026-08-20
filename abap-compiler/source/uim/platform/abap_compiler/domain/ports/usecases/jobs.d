/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.usecases.jobs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Application use case: query / manage compilation jobs.
interface IManageJobsUseCase {

    /// Retrieves a compilation job by its ID.
    /// @param tenantId The tenant ID.
    /// @param id The ID of the compilation job to retrieve.
    CompilationJob getJob(TenantId tenantId, CompilationJobId id);

    /// Lists all compilation jobs for a given tenant.
    /// @param tenantId The tenant ID.
    CompilationJob[] listJobs(TenantId tenantId);

    /// Lists all compilation jobs for a given tenant and ABAP program.
    /// @param tenantId The tenant ID.
    /// @param programId The ID of the ABAP program.
    CompilationJob[] listJobs(TenantId tenantId, AbapProgramId programId);

    /// Deletes a compilation job from the repository.
    /// @param tenantId The tenant ID.
    /// @param id The ID of the compilation job to delete.
    UsecaseResult deleteJob(TenantId tenantId, CompilationJobId id);
}

