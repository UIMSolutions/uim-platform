/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.container;

import uim.platform.agentry;
import uim.platform.agentry.presentation.http;

mixin(ShowModule!());

@safe:

struct Container {
    ManageMobileApplicationsUseCase manageMobileApplicationsUseCase;
    ManageAppDefinitionsUseCase manageAppDefinitionsUseCase;
    ManageAppVersionsUseCase manageAppVersionsUseCase;
    ManageDevicesUseCase manageDevicesUseCase;
    ManageSyncSessionsUseCase manageSyncSessionsUseCase;
    ManageBackendConnectionsUseCase manageBackendConnectionsUseCase;
    ManageDeploymentsUseCase manageDeploymentsUseCase;

    MobileApplicationController mobileApplicationController;
    AppDefinitionController appDefinitionController;
    AppVersionController appVersionController;
    DeviceController deviceController;
    SyncSessionController syncSessionController;
    BackendConnectionController backendConnectionController;
    DeploymentController deploymentController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto mobileApplicationRepo = new MobileApplicationRepository();
    auto appDefinitionRepo = new AppDefinitionRepository();
    auto appVersionRepo = new AppVersionRepository();
    auto deviceRepo = new DeviceRepository();
    auto syncSessionRepo = new SyncSessionRepository();
    auto backendConnectionRepo = new BackendConnectionRepository();
    auto deploymentRepo = new DeploymentRepository();

    // Use Cases
    c.manageMobileApplicationsUseCase = new ManageMobileApplicationsUseCase(mobileApplicationRepo);
    c.manageAppDefinitionsUseCase = new ManageAppDefinitionsUseCase(appDefinitionRepo);
    c.manageAppVersionsUseCase = new ManageAppVersionsUseCase(appVersionRepo);
    c.manageDevicesUseCase = new ManageDevicesUseCase(deviceRepo);
    c.manageSyncSessionsUseCase = new ManageSyncSessionsUseCase(syncSessionRepo);
    c.manageBackendConnectionsUseCase = new ManageBackendConnectionsUseCase(backendConnectionRepo);
    c.manageDeploymentsUseCase = new ManageDeploymentsUseCase(deploymentRepo);

    // Controllers
    c.mobileApplicationController = new MobileApplicationController(c.manageMobileApplicationsUseCase);
    c.appDefinitionController = new AppDefinitionController(c.manageAppDefinitionsUseCase);
    c.appVersionController = new AppVersionController(c.manageAppVersionsUseCase);
    c.deviceController = new DeviceController(c.manageDevicesUseCase);
    c.syncSessionController = new SyncSessionController(c.manageSyncSessionsUseCase);
    c.backendConnectionController = new BackendConnectionController(c.manageBackendConnectionsUseCase);
    c.deploymentController = new DeploymentController(c.manageDeploymentsUseCase);
    c.healthController = new HealthController();

    return c;
}
