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

    // container.buildingBlockController = new BuildingBlockController(container.manageBlocksUseCase);
    container.healthController = new HealthController("architecture", "1.0.0", "TOGAF Building Blocks Service");

    return container;
}
