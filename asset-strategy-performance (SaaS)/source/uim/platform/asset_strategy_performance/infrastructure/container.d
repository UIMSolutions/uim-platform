/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.container;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Container {
    ManageEquipmentUseCase manageEquipmentUseCase;
    ManageModelsUseCase manageModelsUseCase;
    ManageLocationsUseCase manageLocationsUseCase;
    ManageFailureModesUseCase manageFailureModesUseCase;
    ManageAssessmentsUseCase manageAssessmentsUseCase;
    ManageInstructionsUseCase manageInstructionsUseCase;
    ManageFunctionsUseCase manageFunctionsUseCase;
    ManageIndicatorsUseCase manageIndicatorsUseCase;

    EquipmentController equipmentController;
    ModelController modelController;
    LocationController locationController;
    FailureModeController failureModeController;
    AssessmentController assessmentController;
    InstructionController instructionController;
    FunctionController functionController;
    IndicatorController indicatorController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto equipmentRepo = new MemoryEquipmentRepository();
    auto modelRepo = new MemoryModelRepository();
    auto locationRepo = new MemoryLocationRepository();
    auto failureModeRepo = new MemoryFailureModeRepository();
    auto assessmentRepo = new MemoryAssessmentRepository();
    auto instructionRepo = new MemoryInstructionRepository();
    auto functionRepo = new MemoryFunctionRepository();
    auto indicatorRepo = new MemoryIndicatorRepository();

    // Use Cases
    c.manageEquipmentUseCase = new ManageEquipmentUseCase(equipmentRepo);
    c.manageModelsUseCase = new ManageModelsUseCase(modelRepo);
    c.manageLocationsUseCase = new ManageLocationsUseCase(locationRepo);
    c.manageFailureModesUseCase = new ManageFailureModesUseCase(failureModeRepo);
    c.manageAssessmentsUseCase = new ManageAssessmentsUseCase(assessmentRepo);
    c.manageInstructionsUseCase = new ManageInstructionsUseCase(instructionRepo);
    c.manageFunctionsUseCase = new ManageFunctionsUseCase(functionRepo);
    c.manageIndicatorsUseCase = new ManageIndicatorsUseCase(indicatorRepo);

    // Controllers
    c.equipmentController = new EquipmentController(c.manageEquipmentUseCase);
    c.modelController = new ModelController(c.manageModelsUseCase);
    c.locationController = new LocationController(c.manageLocationsUseCase);
    c.failureModeController = new FailureModeController(c.manageFailureModesUseCase);
    c.assessmentController = new AssessmentController(c.manageAssessmentsUseCase);
    c.instructionController = new InstructionController(c.manageInstructionsUseCase);
    c.functionController = new FunctionController(c.manageFunctionsUseCase);
    c.indicatorController = new IndicatorController(c.manageIndicatorsUseCase);
    c.healthController = new HealthController();

    return c;
}
