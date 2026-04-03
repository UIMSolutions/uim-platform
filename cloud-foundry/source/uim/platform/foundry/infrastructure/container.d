/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.container;

import uim.platform.foundry.infrastructure.config;

// Repositories
import uim.platform.foundry.infrastructure.persistence.memory.org;
import uim.platform.foundry.infrastructure.persistence.memory.space;
import uim.platform.foundry.infrastructure.persistence.memory.app;
import uim.platform.foundry.infrastructure.persistence.memory.service_instance;
import uim.platform.foundry.infrastructure.persistence.memory.service_binding;
import uim.platform.foundry.infrastructure.persistence.memory.route;
import uim.platform.foundry.infrastructure.persistence.memory.domain;
import uim.platform.foundry.infrastructure.persistence.memory.buildpack;

// Domain Services
import uim.platform.foundry.domain.services.app_lifecycle_manager;
import uim.platform.foundry.domain.services.route_resolver;

// Use Cases
import uim.platform.foundry.application.usecases.manage_orgs;
import uim.platform.foundry.application.usecases.manage_spaces;
import uim.platform.foundry.application.usecases.manage_apps;
import uim.platform.foundry.application.usecases.manage_services;
import uim.platform.foundry.application.usecases.manage_routes;
import uim.platform.foundry.application.usecases.manage_buildpacks;
import uim.platform.foundry.application.usecases.monitor_apps;

// Controllers
import uim.platform.foundry.presentation.http.org;
import uim.platform.foundry.presentation.http.space;
import uim.platform.foundry.presentation.http.app;
import uim.platform.foundry.presentation.http.service;
import uim.platform.foundry.presentation.http.route;
import uim.platform.foundry.presentation.http.buildpack;
import uim.platform.foundry.presentation.http.monitoring;
import uim.platform.foundry.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  MemoryOrgRepository orgRepo;
  MemorySpaceRepository spaceRepo;
  MemoryAppRepository appRepo;
  MemoryServiceInstanceRepository serviceInstanceRepo;
  MemoryServiceBindingRepository serviceBindingRepo;
  MemoryRouteRepository routeRepo;
  MemoryDomainRepository domainRepo;
  MemoryBuildpackRepository buildpackRepo;

  // Domain services
  AppLifecycleManager appLifecycle;
  RouteResolver routeResolver;

  // Use cases (application layer)
  ManageOrgsUseCase manageOrgs;
  ManageSpacesUseCase manageSpaces;
  ManageAppsUseCase manageApps;
  ManageServicesUseCase manageServices;
  ManageRoutesUseCase manageRoutes;
  ManageBuildpacksUseCase manageBuildpacks;
  MonitorAppsUseCase monitorApps;

  // Controllers (driving adapters)
  OrgController orgController;
  SpaceController spaceController;
  AppController appController;
  ServiceController serviceController;
  RouteController routeController;
  BuildpackController buildpackController;
  MonitoringController monitoringController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
  Container c;

  // Infrastructure adapters (driven ports)
  c.orgRepo = new MemoryOrgRepository();
  c.spaceRepo = new MemorySpaceRepository();
  c.appRepo = new MemoryAppRepository();
  c.serviceInstanceRepo = new MemoryServiceInstanceRepository();
  c.serviceBindingRepo = new MemoryServiceBindingRepository();
  c.routeRepo = new MemoryRouteRepository();
  c.domainRepo = new MemoryDomainRepository();
  c.buildpackRepo = new MemoryBuildpackRepository();

  // Domain services
  c.appLifecycle = new AppLifecycleManager(c.appRepo, c.orgRepo, c.spaceRepo);
  c.routeResolver = new RouteResolver(c.routeRepo, c.domainRepo);

  // Application use cases
  c.manageOrgs = new ManageOrgsUseCase(c.orgRepo, c.spaceRepo);
  c.manageSpaces = new ManageSpacesUseCase(c.spaceRepo, c.orgRepo);
  c.manageApps = new ManageAppsUseCase(c.appRepo, c.appLifecycle);
  c.manageServices = new ManageServicesUseCase(c.serviceInstanceRepo, c.serviceBindingRepo);
  c.manageRoutes = new ManageRoutesUseCase(c.routeRepo, c.domainRepo, c.routeResolver);
  c.manageBuildpacks = new ManageBuildpacksUseCase(c.buildpackRepo);
  c.monitorApps = new MonitorAppsUseCase(c.appRepo, c.serviceInstanceRepo, c.routeRepo);

  // Presentation controllers (driving adapters)
  c.orgController = new OrgController(c.manageOrgs);
  c.spaceController = new SpaceController(c.manageSpaces);
  c.appController = new AppController(c.manageApps);
  c.serviceController = new ServiceController(c.manageServices);
  c.routeController = new RouteController(c.manageRoutes);
  c.buildpackController = new BuildpackController(c.manageBuildpacks);
  c.monitoringController = new MonitoringController(c.monitorApps);
  c.healthController = new HealthController("cloud-foundry");

  return c;
}
