/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.container;

// import uim.platform.html_repository.infrastructure.config;

// // Repositories
// import uim.platform.html_repository.infrastructure.persistence.memory.html_app_repository;
// import uim.platform.html_repository.infrastructure.persistence.memory.app_version_repository;
// import uim.platform.html_repository.infrastructure.persistence.memory.app_file_repository;
// import uim.platform.html_repository.infrastructure.persistence.memory.service_instance_repository;
// import uim.platform.html_repository.infrastructure.persistence.memory.deployment_record_repository;
// import uim.platform.html_repository.infrastructure.persistence.memory.app_route_repository;
// import uim.platform.html_repository.infrastructure.persistence.memory.content_cache_repository;

// // Use Cases
// import uim.platform.html_repository.application.usecases.manage.html_apps;
// import uim.platform.html_repository.application.usecases.manage.app_versions;
// import uim.platform.html_repository.application.usecases.manage.app_files;
// import uim.platform.html_repository.application.usecases.manage.service_instances;
// import uim.platform.html_repository.application.usecases.deploy_application;
// import uim.platform.html_repository.application.usecases.manage.app_routes;
// import uim.platform.html_repository.application.usecases.manage.content_cache;
// import uim.platform.html_repository.application.usecases.get_deployment_history;
// import uim.platform.html_repository.application.usecases.get_overview;

// // Controllers
// import uim.platform.html_repository.presentation.http.controllers.html_app;
// import uim.platform.html_repository.presentation.http.controllers.app_version;
// import uim.platform.html_repository.presentation.http.controllers.app_file;
// import uim.platform.html_repository.presentation.http.controllers.service_instance;
// import uim.platform.html_repository.presentation.http.controllers.deployment;
// import uim.platform.html_repository.presentation.http.controllers.app_route;
// import uim.platform.html_repository.presentation.http.controllers.content_cache;
// import uim.platform.html_repository.presentation.http.controllers.content;
// import uim.platform.html_repository.presentation.http.controllers.overview;
// import uim.platform.html_repository.presentation.http.controllers.health;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct Container {
  // Repositories (driven adapters)
  HtmlAppMemoryRepository appRepo;
  AppVersionMemoryRepository versionRepo;
  AppFileMemoryRepository fileRepo;
  ServiceInstanceMemoryRepository instanceRepo;
  DeploymentRecordMemoryRepository deploymentRepo;
  AppRouteMemoryRepository routeRepo;
  ContentCacheMemoryRepository cacheRepo;

  // Use cases (application layer)
  ManageHtmlAppsUseCase manageApps;
  ManageAppVersionsUseCase manageVersions;
  ManageAppFilesUseCase manageFiles;
  ManageServiceInstancesUseCase manageInstances;
  DeployApplicationUseCase deployApp;
  ManageAppRoutesUseCase manageRoutes;
  ManageContentCacheUseCase manageCache;
  GetDeploymentHistoryUseCase getHistory;
  GetOverviewUseCase getOverview;

  // Controllers (driving adapters)
  HtmlAppController htmlAppController;
  AppVersionController appVersionController;
  AppFileController appFileController;
  ServiceInstanceController serviceInstanceController;
  DeploymentController deploymentController;
  AppRouteController appRouteController;
  ContentCacheController contentCacheController;
  ContentController contentController;
  OverviewController overviewController;
  HealthController healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.appRepo = new HtmlAppMemoryRepository();
  c.versionRepo = new AppVersionMemoryRepository();
  c.fileRepo = new AppFileMemoryRepository();
  c.instanceRepo = new ServiceInstanceMemoryRepository();
  c.deploymentRepo = new DeploymentRecordMemoryRepository();
  c.routeRepo = new AppRouteMemoryRepository();
  c.cacheRepo = new ContentCacheMemoryRepository();

  // Application use cases
  c.manageApps = new ManageHtmlAppsUseCase(c.appRepo);
  c.manageVersions = new ManageAppVersionsUseCase(c.versionRepo);
  c.manageFiles = new ManageAppFilesUseCase(c.fileRepo);
  c.manageInstances = new ManageServiceInstancesUseCase(c.instanceRepo);
  c.deployApp = new DeployApplicationUseCase(c.deploymentRepo, c.appRepo, c.versionRepo);
  c.manageRoutes = new ManageAppRoutesUseCase(c.routeRepo);
  c.manageCache = new ManageContentCacheUseCase(c.cacheRepo);
  c.getHistory = new GetDeploymentHistoryUseCase(c.deploymentRepo);
  c.getOverview = new GetOverviewUseCase(c.appRepo, c.versionRepo, c.fileRepo, c.instanceRepo, c.deploymentRepo, c.routeRepo, c.cacheRepo);

  // Presentation controllers
  c.htmlAppController = new HtmlAppController(c.manageApps);
  c.appVersionController = new AppVersionController(c.manageVersions);
  c.appFileController = new AppFileController(c.manageFiles);
  c.serviceInstanceController = new ServiceInstanceController(c.manageInstances);
  c.deploymentController = new DeploymentController(c.deployApp, c.getHistory);
  c.appRouteController = new AppRouteController(c.manageRoutes);
  c.contentCacheController = new ContentCacheController(c.manageCache);
  c.contentController = new ContentController(c.manageFiles, c.manageCache);
  c.overviewController = new OverviewController(c.getOverview);
  c.healthController = new HealthController("html-repository");

  return c;
}
