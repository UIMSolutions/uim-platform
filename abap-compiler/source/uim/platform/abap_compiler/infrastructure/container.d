/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.infrastructure.container;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Dependency-injection container wired at startup.
struct Container {
    // Driven adapters (repositories)
    MemoryAbapProgramRepository    programRepo;
    MemoryCompilationJobRepository jobRepo;

    // Application use cases
    ManageProgramsUseCase  managePrograms;
    ManageJobsUseCase      manageJobs;
    CompileUseCase         compile;

    // Driving adapters (HTTP controllers)
    ProgramController  programController;
    CompileController  compileController;
    JobController      jobController;
    HealthController   healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Infrastructure
    c.programRepo = new MemoryAbapProgramRepository();
    c.jobRepo     = new MemoryCompilationJobRepository();

    // Application
    c.managePrograms = new ManageProgramsUseCase(c.programRepo);
    c.manageJobs     = new ManageJobsUseCase(c.jobRepo);
    c.compile        = new CompileUseCase(c.programRepo, c.jobRepo);

    // Presentation
    c.programController = new ProgramController(c.managePrograms);
    c.compileController = new CompileController(c.compile);
    c.jobController     = new JobController(c.manageJobs);
    c.healthController  = new HealthController();

    return c;
}
