/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.container;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

struct Container {
    // Repositories (driven adapters)
    MemoryTranslationProjectRepository translationProjectRepo;
    MemoryGlossaryEntryRepository glossaryEntryRepo;
    MemoryTranslationJobRepository translationJobRepo;

    // Domain services
    TranslationEngine translationEngine;

    // Use cases (application layer)
    ManageTranslationProjectsUseCase manageTranslationProjects;
    ManageGlossaryEntriesUseCase manageGlossaryEntries;
    ManageTranslationJobsUseCase manageTranslationJobs;
    PerformTranslationUseCase performTranslation;

    // Controllers (driving adapters)
    LanguageController languageController;
    DomainController domainController;
    TextTypeController textTypeController;
    TranslationController translationController;
    TranslationProjectController translationProjectController;
    GlossaryController glossaryController;
    DocumentTranslationController documentTranslationController;
    TranslationJobController translationJobController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Infrastructure adapters
    c.translationProjectRepo = new MemoryTranslationProjectRepository();
    c.glossaryEntryRepo = new MemoryGlossaryEntryRepository();
    c.translationJobRepo = new MemoryTranslationJobRepository();

    // Domain services
    c.translationEngine = new TranslationEngine();

    // Application use cases
    c.manageTranslationProjects = new ManageTranslationProjectsUseCase(c.translationProjectRepo);
    c.manageGlossaryEntries = new ManageGlossaryEntriesUseCase(c.glossaryEntryRepo);
    c.manageTranslationJobs = new ManageTranslationJobsUseCase(c.translationJobRepo, c.translationEngine);
    c.performTranslation = new PerformTranslationUseCase(c.translationEngine);

    // Presentation controllers
    c.languageController = new LanguageController(c.performTranslation);
    c.domainController = new DomainController();
    c.textTypeController = new TextTypeController();
    c.translationController = new TranslationController(c.performTranslation);
    c.translationProjectController = new TranslationProjectController(c.manageTranslationProjects);
    c.glossaryController = new GlossaryController(c.manageGlossaryEntries);
    c.documentTranslationController = new DocumentTranslationController(c.performTranslation);
    c.translationJobController = new TranslationJobController(c.manageTranslationJobs);
    c.healthController = new HealthController("translation");

    return c;
}
