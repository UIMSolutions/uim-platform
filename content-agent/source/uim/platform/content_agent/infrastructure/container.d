/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.container;

import uim.platform.content_agent.infrastructure.config;

// Repositories
import uim.platform.content_agent.infrastructure.persistence.memory.content_packages;
import uim.platform.content_agent.infrastructure.persistence.memory.content_providers;
import uim.platform.content_agent.infrastructure.persistence.memory.transport_requests;
import uim.platform.content_agent.infrastructure.persistence.memory.export_jobs;
import uim.platform.content_agent.infrastructure.persistence.memory.import_jobs;
import uim.platform.content_agent.infrastructure.persistence.memory.transport_queues;
import uim.platform.content_agent.infrastructure.persistence.memory.content_activities;

// Use Cases
import uim.platform.content_agent.application.usecases.manage.content_packages;
import uim.platform.content_agent.application.usecases.manage.content_providers;
import uim.platform.content_agent.application.usecases.manage.transport_requests;
import uim.platform.content_agent.application.usecases.export_content;
import uim.platform.content_agent.application.usecases.import_content;
import uim.platform.content_agent.application.usecases.manage.transport_queues;
import uim.platform.content_agent.application.usecases.monitor_activities;

// Controllers
import uim.platform.content_agent.presentation.http.package;
import uim.platform.content_agent.presentation.http.provider;
import uim.platform.content_agent.presentation.http.transport;
import uim.platform.content_agent.presentation.http.export;
import uim.platform.content_agent.presentation.http.import ;
import uim.platform.content_agent.presentation.http.queue;
import uim.platform.content_agent.presentation.http.activity;
import uim.platform.content_agent.presentation.http.health;



/// Dependency injection container - wires all layers together.
struct Container {

  

  // Repositories (driven adapters)
  MemoryContentPackageRepository packageRepo;

  MemoryContentProviderRepository providerRepo;
  MemoryTransportRequestRepository transportRequestRepo;
  MemoryExportJobRepository exportJobRepo;
  MemoryImportJobRepository importJobRepo;
  MemoryTransportQueueRepository queueRepo;
  MemoryContentActivityRepository activityRepo;

  // Use cases (application layer)
  ManageContentPackagesUseCase managePackages;
  ManageContentProvidersUseCase manageProviders;
  ManageTransportRequestsUseCase manageTransports;
  ExportContentUseCase exportContent;
  ImportContentUseCase importContent;
  ManageTransportQueuesUseCase manageQueues;
  MonitorActivitiesUseCase monitorActivities;

  // Controllers (driving adapters)
  PackageController packageController;
  ProviderController providerController;
  TransportController transportController;
  ExportController exportController;
  ImportController importController;
  QueueController queueController;
  ActivityController activityController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.packageRepo = new MemoryContentPackageRepository();
  c.providerRepo = new MemoryContentProviderRepository();
  c.transportRequestRepo = new MemoryTransportRequestRepository();
  c.exportJobRepo = new MemoryExportJobRepository();
  c.importJobRepo = new MemoryImportJobRepository();
  c.queueRepo = new MemoryTransportQueueRepository();
  c.activityRepo = new MemoryContentActivityRepository();

  // Application use cases
  c.managePackages = new ManageContentPackagesUseCase(c.packageRepo, c.providerRepo, c.activityRepo);
  c.manageProviders = new ManageContentProvidersUseCase(c.providerRepo, c.activityRepo);
  c.manageTransports = new ManageTransportRequestsUseCase(c.transportRequestRepo,
      c.packageRepo, c.queueRepo, c.activityRepo);
  c.exportContent = new ExportContentUseCase(c.exportJobRepo, c.packageRepo, c.activityRepo);
  c.importContent = new ImportContentUseCase(c.importJobRepo, c.packageRepo, c.activityRepo);
  c.manageQueues = new ManageTransportQueuesUseCase(c.queueRepo, c.activityRepo);
  c.monitorActivities = new MonitorActivitiesUseCase(c.activityRepo);

  // Presentation controllers
  c.packageController = new PackageController(c.managePackages);
  c.providerController = new ProviderController(c.manageProviders);
  c.transportController = new TransportController(c.manageTransports);
  c.exportController = new ExportController(c.exportContent);
  c.importController = new ImportController(c.importContent);
  c.queueController = new QueueController(c.manageQueues);
  c.activityController = new ActivityController(c.monitorActivities);
  c.healthController = new HealthController("content-agent");

  return c;
}
