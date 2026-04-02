module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.content_package_repo;
import infrastructure.persistence.memory.content_provider_repo;
import infrastructure.persistence.memory.transport_request_repo;
import infrastructure.persistence.memory.export_job_repo;
import infrastructure.persistence.memory.import_job_repo;
import infrastructure.persistence.memory.transport_queue_repo;
import infrastructure.persistence.memory.content_activity_repo;

// Use Cases
import uim.platform.content_agent.application.usecases.manage_content_packages;
import uim.platform.content_agent.application.usecases.manage_content_providers;
import uim.platform.content_agent.application.usecases.manage_transport_requests;
import uim.platform.content_agent.application.usecases.export_content;
import uim.platform.content_agent.application.usecases.import_content;
import uim.platform.content_agent.application.usecases.manage_transport_queues;
import uim.platform.content_agent.application.usecases.monitor_activities;

// Controllers
import presentation.http.package;
import presentation.http.provider;
import presentation.http.transport;
import presentation.http.export;
import presentation.http.import;
import presentation.http.queue;
import presentation.http.activity;
import presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryContentPackageRepository packageRepo;
    InMemoryContentProviderRepository providerRepo;
    InMemoryTransportRequestRepository transportRequestRepo;
    InMemoryExportJobRepository exportJobRepo;
    InMemoryImportJobRepository importJobRepo;
    InMemoryTransportQueueRepository queueRepo;
    InMemoryContentActivityRepository activityRepo;

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
Container buildContainer(AppConfig config)
{
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
    c.manageTransports = new ManageTransportRequestsUseCase(c.transportRequestRepo, c.packageRepo, c.queueRepo, c.activityRepo);
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
