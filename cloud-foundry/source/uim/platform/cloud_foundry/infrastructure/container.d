module uim.platform.cloud_foundry.infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_org_repo;
import infrastructure.persistence.in_memory_space_repo;
import infrastructure.persistence.in_memory_app_repo;
import infrastructure.persistence.in_memory_service_instance_repo;
import infrastructure.persistence.in_memory_service_binding_repo;
import infrastructure.persistence.in_memory_route_repo;
import infrastructure.persistence.in_memory_domain_repo;
import infrastructure.persistence.in_memory_buildpack_repo;

// Domain Services
import uim.platform.cloud_foundry.domain.services.app_lifecycle_manager;
import uim.platform.cloud_foundry.domain.services.route_resolver;

// Use Cases
import application.usecases.manage_orgs;
import application.usecases.manage_spaces;
import application.usecases.manage_apps;
import application.usecases.manage_services;
import application.usecases.manage_routes;
import application.usecases.manage_buildpacks;
import application.usecases.monitor_apps;

// Controllers
import presentation.http.org;
import presentation.http.space;
import presentation.http.app;
import presentation.http.service;
import presentation.http.route;
import presentation.http.buildpack;
import presentation.http.monitoring;
import presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  InMemoryOrgRepository orgRepo;
  InMemorySpaceRepository spaceRepo;
  InMemoryAppRepository appRepo;
  InMemoryServiceInstanceRepository serviceInstanceRepo;
  InMemoryServiceBindingRepository serviceBindingRepo;
  InMemoryRouteRepository routeRepo;
  InMemoryDomainRepository domainRepo;
  InMemoryBuildpackRepository buildpackRepo;

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
  c.orgRepo = new InMemoryOrgRepository();
  c.spaceRepo = new InMemorySpaceRepository();
  c.appRepo = new InMemoryAppRepository();
  c.serviceInstanceRepo = new InMemoryServiceInstanceRepository();
  c.serviceBindingRepo = new InMemoryServiceBindingRepository();
  c.routeRepo = new InMemoryRouteRepository();
  c.domainRepo = new InMemoryDomainRepository();
  c.buildpackRepo = new InMemoryBuildpackRepository();

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
  c.healthController = new HealthController();

  return c;
}
