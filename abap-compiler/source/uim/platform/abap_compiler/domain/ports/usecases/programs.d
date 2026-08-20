/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.ports.usecases.programs;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Application use case: CRUD management of ABAP source programs in the repository.
interface IManageProgramsUseCase {

    /// Creates a new ABAP program in the repository.
    /// @param r The request containing the program details.
    UsecaseResult createProgram(CreateProgramRequest r);

    /// Retrieves an ABAP program by its ID.
    /// @param tenantId The tenant ID.
    /// @param programId The ID of the ABAP program to retrieve.
    AbapProgram getProgram(TenantId tenantId, AbapProgramId programId);

    /// Lists all ABAP programs for a given tenant.
    /// @param tenantId The tenant ID.
    AbapProgram[] listPrograms(TenantId tenantId);

    /// Updates an existing ABAP program in the repository.
    /// @param r The request containing the updated program details.    
    UsecaseResult updateProgram(UpdateProgramRequest r);

    /// Deletes an ABAP program from the repository.
    /// @param tenantId The tenant ID.
    /// @param programId The ID of the ABAP program to delete.
    UsecaseResult deleteProgram(TenantId tenantId, AbapProgramId programId);

    /// Counts the number of ABAP programs for a given tenant.
    /// @param tenantId The tenant ID.
    size_t countPrograms(TenantId tenantId);

}

