/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.container;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct Container {
    ManageApplicationsUseCase manageApplicationsUseCase;
    ManagePagesUseCase managePagesUseCase;
    ManageUIComponentsUseCase manageUIComponentsUseCase;
    ManageDataEntitiesUseCase manageDataEntitiesUseCase;
    ManageDataConnectionsUseCase manageDataConnectionsUseCase;
    ManageLogicFlowsUseCase manageLogicFlowsUseCase;
    ManageAppBuildsUseCase manageAppBuildsUseCase;
    ManageProjectMembersUseCase manageProjectMembersUseCase;

    ApplicationController applicationController;
    PageController pageController;
    UIComponentController uiComponentController;
    DataEntityController dataEntityController;
    DataConnectionController dataConnectionController;
    LogicFlowController logicFlowController;
    AppBuildController appBuildController;
    ProjectMemberController projectMemberController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto applicationRepo = new ApplicationRepository();
    auto pageRepo = new PageRepository();
    auto uiComponentRepo = new UIComponentRepository();
    auto dataEntityRepo = new DataEntityRepository();
    auto dataConnectionRepo = new DataConnectionRepository();
    auto logicFlowRepo = new LogicFlowRepository();
    auto appBuildRepo = new AppBuildRepository();
    auto projectMemberRepo = new ProjectMemberRepository();

    // Use Cases
    c.manageApplicationsUseCase = new ManageApplicationsUseCase(applicationRepo);
    c.managePagesUseCase = new ManagePagesUseCase(pageRepo);
    c.manageUIComponentsUseCase = new ManageUIComponentsUseCase(uiComponentRepo);
    c.manageDataEntitiesUseCase = new ManageDataEntitiesUseCase(dataEntityRepo);
    c.manageDataConnectionsUseCase = new ManageDataConnectionsUseCase(dataConnectionRepo);
    c.manageLogicFlowsUseCase = new ManageLogicFlowsUseCase(logicFlowRepo);
    c.manageAppBuildsUseCase = new ManageAppBuildsUseCase(appBuildRepo);
    c.manageProjectMembersUseCase = new ManageProjectMembersUseCase(projectMemberRepo);

    // Controllers
    c.applicationController = new ApplicationController(c.manageApplicationsUseCase);
    c.pageController = new PageController(c.managePagesUseCase);
    c.uiComponentController = new UIComponentController(c.manageUIComponentsUseCase);
    c.dataEntityController = new DataEntityController(c.manageDataEntitiesUseCase);
    c.dataConnectionController = new DataConnectionController(c.manageDataConnectionsUseCase);
    c.logicFlowController = new LogicFlowController(c.manageLogicFlowsUseCase);
    c.appBuildController = new AppBuildController(c.manageAppBuildsUseCase);
    c.projectMemberController = new ProjectMemberController(c.manageProjectMembersUseCase);
    c.healthController = new HealthController();

    return c;
}
