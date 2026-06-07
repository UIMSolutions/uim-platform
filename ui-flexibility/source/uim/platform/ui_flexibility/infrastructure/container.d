/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.container;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

struct Container {
  // Repositories
  FlexChangeRepository        changeRepo;
  FlexVariantRepository       variantRepo;
  FlexVersionRepository       versionRepo;
  FlexDraftRepository         draftRepo;
  FlexPersonalizationRepository personalizationRepo;
  FlexApplicationRepository   applicationRepo;

  // Use cases
  ManageFlexChangesUseCase        changeUseCase;
  ManageFlexVariantsUseCase       variantUseCase;
  ManageFlexVersionsUseCase       versionUseCase;
  ManageFlexDraftsUseCase         draftUseCase;
  ManageFlexPersonalizationsUseCase personalizationUseCase;
  ManageFlexApplicationsUseCase   applicationUseCase;

  // HTTP Controllers
  FlexChangesController       changeController;
  FlexVariantsController      variantController;
  FlexVersionsController      versionController;
  FlexDraftsController        draftController;
  FlexPersonalizationsController personalizationController;
  FlexApplicationsController  applicationController;
  HealthController            healthController;
}

Container buildContainer(SrvConfig config) @trusted {
  Container c;

  // ── Repositories ─────────────────────────────────────────────────────────
  final switch (config.storage) {
    case StorageBackend.memory_:
      c.changeRepo          = new MemoryFlexChangeRepository();
      c.variantRepo         = new MemoryFlexVariantRepository();
      c.versionRepo         = new MemoryFlexVersionRepository();
      c.draftRepo           = new MemoryFlexDraftRepository();
      c.personalizationRepo = new MemoryFlexPersonalizationRepository();
      c.applicationRepo     = new MemoryFlexApplicationRepository();
      break;

    case StorageBackend.files_:
      c.changeRepo          = new FileFlexChangeRepository(config.dataPath);
      // others use memory fallback; file backends can be added incrementally
      c.variantRepo         = new MemoryFlexVariantRepository();
      c.versionRepo         = new MemoryFlexVersionRepository();
      c.draftRepo           = new MemoryFlexDraftRepository();
      c.personalizationRepo = new MemoryFlexPersonalizationRepository();
      c.applicationRepo     = new MemoryFlexApplicationRepository();
      break;

    case StorageBackend.mongodb_:
      c.changeRepo          = new MongoFlexChangeRepository(config.mongoUri);
      c.variantRepo         = new MemoryFlexVariantRepository();
      c.versionRepo         = new MemoryFlexVersionRepository();
      c.draftRepo           = new MemoryFlexDraftRepository();
      c.personalizationRepo = new MemoryFlexPersonalizationRepository();
      c.applicationRepo     = new MemoryFlexApplicationRepository();
      break;
  }

  // ── Use cases ─────────────────────────────────────────────────────────────
  c.changeUseCase          = new ManageFlexChangesUseCase(c.changeRepo);
  c.variantUseCase         = new ManageFlexVariantsUseCase(c.variantRepo);
  c.versionUseCase         = new ManageFlexVersionsUseCase(c.versionRepo);
  c.draftUseCase           = new ManageFlexDraftsUseCase(c.draftRepo);
  c.personalizationUseCase = new ManageFlexPersonalizationsUseCase(c.personalizationRepo);
  c.applicationUseCase     = new ManageFlexApplicationsUseCase(c.applicationRepo);

  // ── Controllers ───────────────────────────────────────────────────────────
  c.changeController          = new FlexChangesController(c.changeUseCase);
  c.variantController         = new FlexVariantsController(c.variantUseCase);
  c.versionController         = new FlexVersionsController(c.versionUseCase);
  c.draftController           = new FlexDraftsController(c.draftUseCase);
  c.personalizationController = new FlexPersonalizationsController(c.personalizationUseCase);
  c.applicationController     = new FlexApplicationsController(c.applicationUseCase);
  c.healthController          = new HealthController();

  return c;
}
