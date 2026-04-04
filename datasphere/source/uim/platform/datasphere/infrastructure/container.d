/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.container;

import uim.platform.datasphere.infrastructure.config;

// Repositories
import uim.platform.datasphere.infrastructure.persistence.memory.space_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.connection_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.remote_table_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.data_flow_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.view_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.task_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.task_chain_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.data_access_control_repo;
import uim.platform.datasphere.infrastructure.persistence.memory.catalog_asset_repo;

// Use Cases
import uim.platform.datasphere.application.usecases.manage.spaces;
import uim.platform.datasphere.application.usecases.manage.connections;
import uim.platform.datasphere.application.usecases.manage.remote_tables;
import uim.platform.datasphere.application.usecases.manage.data_flows;
import uim.platform.datasphere.application.usecases.manage.views;
import uim.platform.datasphere.application.usecases.manage.tasks;
import uim.platform.datasphere.application.usecases.manage.task_chains;
import uim.platform.datasphere.application.usecases.manage.data_access_controls;
import uim.platform.datasphere.application.usecases.manage.catalog_assets;

// Controllers
import uim.platform.datasphere.presentation.http.controllers.space;
import uim.platform.datasphere.presentation.http.controllers.connection;
import uim.platform.datasphere.presentation.http.controllers.remote_table;
import uim.platform.datasphere.presentation.http.controllers.data_flow;
import uim.platform.datasphere.presentation.http.controllers.view_;
import uim.platform.datasphere.presentation.http.controllers.task;
import uim.platform.datasphere.presentation.http.controllers.task_chain;
import uim.platform.datasphere.presentation.http.controllers.data_access_control;
import uim.platform.datasphere.presentation.http.controllers.catalog_asset;
import uim.platform.datasphere.presentation.http.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemorySpaceRepository spaceRepo;
  MemoryConnectionRepository connectionRepo;
  MemoryRemoteTableRepository remoteTableRepo;
  MemoryDataFlowRepository dataFlowRepo;
  MemoryViewRepository viewRepo;
  MemoryTaskRepository taskRepo;
  MemoryTaskChainRepository taskChainRepo;
  MemoryDataAccessControlRepository dataAccessControlRepo;
  MemoryCatalogAssetRepository catalogAssetRepo;

  // Use cases (application layer)
  ManageSpacesUseCase manageSpaces;
  ManageConnectionsUseCase manageConnections;
  ManageRemoteTablesUseCase manageRemoteTables;
  ManageDataFlowsUseCase manageDataFlows;
  ManageViewsUseCase manageViews;
  ManageTasksUseCase manageTasks;
  ManageTaskChainsUseCase manageTaskChains;
  ManageDataAccessControlsUseCase manageDataAccessControls;
  ManageCatalogAssetsUseCase manageCatalogAssets;

  // Controllers (driving adapters)
  SpaceController spaceController;
  ConnectionController connectionController;
  RemoteTableController remoteTableController;
  DataFlowController dataFlowController;
  ViewController viewController;
  TaskController taskController;
  TaskChainController taskChainController;
  DataAccessControlController dataAccessControlController;
  CatalogAssetController catalogAssetController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.spaceRepo = new MemorySpaceRepository();
  c.connectionRepo = new MemoryConnectionRepository();
  c.remoteTableRepo = new MemoryRemoteTableRepository();
  c.dataFlowRepo = new MemoryDataFlowRepository();
  c.viewRepo = new MemoryViewRepository();
  c.taskRepo = new MemoryTaskRepository();
  c.taskChainRepo = new MemoryTaskChainRepository();
  c.dataAccessControlRepo = new MemoryDataAccessControlRepository();
  c.catalogAssetRepo = new MemoryCatalogAssetRepository();

  // Application use cases
  c.manageSpaces = new ManageSpacesUseCase(c.spaceRepo);
  c.manageConnections = new ManageConnectionsUseCase(c.connectionRepo);
  c.manageRemoteTables = new ManageRemoteTablesUseCase(c.remoteTableRepo);
  c.manageDataFlows = new ManageDataFlowsUseCase(c.dataFlowRepo);
  c.manageViews = new ManageViewsUseCase(c.viewRepo);
  c.manageTasks = new ManageTasksUseCase(c.taskRepo);
  c.manageTaskChains = new ManageTaskChainsUseCase(c.taskChainRepo);
  c.manageDataAccessControls = new ManageDataAccessControlsUseCase(c.dataAccessControlRepo);
  c.manageCatalogAssets = new ManageCatalogAssetsUseCase(c.catalogAssetRepo);

  // Presentation controllers
  c.spaceController = new SpaceController(c.manageSpaces);
  c.connectionController = new ConnectionController(c.manageConnections);
  c.remoteTableController = new RemoteTableController(c.manageRemoteTables);
  c.dataFlowController = new DataFlowController(c.manageDataFlows);
  c.viewController = new ViewController(c.manageViews);
  c.taskController = new TaskController(c.manageTasks);
  c.taskChainController = new TaskChainController(c.manageTaskChains);
  c.dataAccessControlController = new DataAccessControlController(c.manageDataAccessControls);
  c.catalogAssetController = new CatalogAssetController(c.manageCatalogAssets);
  c.healthController = new HealthController();

  return c;
}
