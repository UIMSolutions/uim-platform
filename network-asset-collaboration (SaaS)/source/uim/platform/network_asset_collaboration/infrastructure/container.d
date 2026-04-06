/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.container;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct Container {
    ManageEquipmentUseCase manageEquipmentUseCase;
    ManageModelsUseCase manageModelsUseCase;
    ManageCompanyProfilesUseCase manageCompanyProfilesUseCase;
    ManageDocumentsUseCase manageDocumentsUseCase;
    ManageAnnouncementsUseCase manageAnnouncementsUseCase;
    ManageFailureModesUseCase manageFailureModesUseCase;
    ManageSparePartsUseCase manageSparePartsUseCase;
    ManageIndicatorsUseCase manageIndicatorsUseCase;

    EquipmentController equipmentController;
    ModelController modelController;
    CompanyProfileController companyProfileController;
    DocumentController documentController;
    AnnouncementController announcementController;
    FailureModeController failureModeController;
    SparePartController sparePartController;
    IndicatorController indicatorController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto equipmentRepo = new MemoryEquipmentRepository();
    auto modelRepo = new MemoryModelRepository();
    auto companyProfileRepo = new MemoryCompanyProfileRepository();
    auto documentRepo = new MemoryDocumentRepository();
    auto announcementRepo = new MemoryAnnouncementRepository();
    auto failureModeRepo = new MemoryFailureModeRepository();
    auto sparePartRepo = new MemorySparePartRepository();
    auto indicatorRepo = new MemoryIndicatorRepository();

    // Use Cases
    c.manageEquipmentUseCase = new ManageEquipmentUseCase(equipmentRepo);
    c.manageModelsUseCase = new ManageModelsUseCase(modelRepo);
    c.manageCompanyProfilesUseCase = new ManageCompanyProfilesUseCase(companyProfileRepo);
    c.manageDocumentsUseCase = new ManageDocumentsUseCase(documentRepo);
    c.manageAnnouncementsUseCase = new ManageAnnouncementsUseCase(announcementRepo);
    c.manageFailureModesUseCase = new ManageFailureModesUseCase(failureModeRepo);
    c.manageSparePartsUseCase = new ManageSparePartsUseCase(sparePartRepo);
    c.manageIndicatorsUseCase = new ManageIndicatorsUseCase(indicatorRepo);

    // Controllers
    c.equipmentController = new EquipmentController(c.manageEquipmentUseCase);
    c.modelController = new ModelController(c.manageModelsUseCase);
    c.companyProfileController = new CompanyProfileController(c.manageCompanyProfilesUseCase);
    c.documentController = new DocumentController(c.manageDocumentsUseCase);
    c.announcementController = new AnnouncementController(c.manageAnnouncementsUseCase);
    c.failureModeController = new FailureModeController(c.manageFailureModesUseCase);
    c.sparePartController = new SparePartController(c.manageSparePartsUseCase);
    c.indicatorController = new IndicatorController(c.manageIndicatorsUseCase);
    c.healthController = new HealthController();

    return c;
}
