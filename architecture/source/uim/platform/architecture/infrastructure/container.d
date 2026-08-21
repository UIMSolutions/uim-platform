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
    BuildingBlockWebController buildingBlockWebController;
    HealthController healthController;

    /// #region UI5 Controllers
    OverviewUi5Controller overviewUi5Controller;
    BuildingBlockUi5Controller buildingBlockUi5Controller;
    ArchitectureBlockUi5Controller architectureBlocksUi5Controller;
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

    auto overviewUi5Model = new OverviewUi5Model();
    auto overviewUi5View = new OverviewUi5View();
    container.overviewUi5Controller = new OverviewUi5Controller(overviewUi5Model, overviewUi5View);

    auto ui5View = new BuildingBlockUi5View();
    auto ui5Model = new BuildingBlockUi5Model(
        container.manageArchitectureBlocks,
        container.manageSolutionBlocks,
        container.manageDataBlocks,
        container.manageBusinessBlocks,
        container.manageTechnologyBlocks
    );
    container.buildingBlockUi5Controller = new BuildingBlockUi5Controller(ui5Model, ui5View);

    auto architectureUi5Model = new ArchitectureBlockUi5Model(container.manageArchitectureBlocks);
    auto architectureUi5View = new ArchitectureBlockUi5View();
    container.architectureBlocksUi5Controller = new ArchitectureBlockUi5Controller(architectureUi5Model, architectureUi5View);

    // container.buildingBlockController = new BuildingBlockController(container.manageBlocksUseCase);
    container.healthController = new HealthController("architecture", "1.0.0"); // , "TOGAF Building Blocks Service");

    return container;
}
