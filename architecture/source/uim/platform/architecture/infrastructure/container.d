module uim.platform.architecture.infrastructure.container;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct Container {
    ManageArchitectureBlocksUseCase manageArchitectureBlocks;
    ManageBusinessBlocksUseCase manageBusinessBlocks;
    ManageDataBlocksUseCase manageDataBlocks;
    ManageSolutionBlocksUseCase manageSolutionBlocks;
    ManageTechnologyBlocksUseCase manageTechnologyBlocks;

    // BuildingBlockController buildingBlockController;
    BuildingBlockPwaController buildingBlockPwaController;
    BuildingBlockUi5Controller buildingBlockUi5Controller;
    BuildingBlockWebController buildingBlockWebController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container container;

    auto architectureBlocks = new ArchitectureBlockRepository();
    auto businessBlocks = new BusinessBlockRepository();
    auto dataBlocks = new DataBlockRepository();
    auto solutionBlocks = new SolutionBlockRepository();
    auto technologyBlocks = new TechnologyBlockRepository(); 

    container.manageArchitectureBlocks = new ManageArchitectureBlocksUseCase(architectureBlocks);
    container.manageBusinessBlocks = new ManageBusinessBlocksUseCase(businessBlocks);
    container.manageDataBlocks = new ManageDataBlocksUseCase(dataBlocks);
    container.manageSolutionBlocks = new ManageSolutionBlocksUseCase(solutionBlocks);
    container.manageTechnologyBlocks = new ManageTechnologyBlocksUseCase(technologyBlocks);

    auto webModel = new BuildingBlockWebModel(
        container.manageArchitectureBlocks,
        container.manageSolutionBlocks,
        container.manageDataBlocks,
        container.manageBusinessBlocks,
        container.manageTechnologyBlocks
    );
    auto webView = new BuildingBlockWebView();
    container.buildingBlockWebController = new BuildingBlockWebController(webModel, webView);

    auto pwaModel = new BuildingBlockPwaModel(
        container.manageArchitectureBlocks,
        container.manageSolutionBlocks,
        container.manageDataBlocks,
        container.manageBusinessBlocks,
        container.manageTechnologyBlocks
    );
    auto pwaView = new BuildingBlockPwaView();
    container.buildingBlockPwaController = new BuildingBlockPwaController(pwaModel, pwaView);

    auto ui5Model = new BuildingBlockUi5Model(
        container.manageArchitectureBlocks,
        container.manageSolutionBlocks,
        container.manageDataBlocks,
        container.manageBusinessBlocks,
        container.manageTechnologyBlocks
    );
    auto ui5View = new BuildingBlockUi5View();
    container.buildingBlockUi5Controller = new BuildingBlockUi5Controller(ui5Model, ui5View);

    // container.buildingBlockController = new BuildingBlockController(container.manageBlocksUseCase);
    container.healthController = new HealthController("architecture", "1.0.0", "TOGAF Building Blocks Service");

    return container;
}
