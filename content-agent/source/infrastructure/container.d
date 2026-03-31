module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_content_package_repo;
import infrastructure.persistence.in_memory_content_provider_repo;
import infrastructure.persistence.in_memory_transport_request_repo;
import infrastructure.persistence.in_memory_export_job_repo;
import infrastructure.persistence.in_memory_import_job_repo;
import infrastructure.persistence.in_memory_transport_queue_repo;
import infrastructure.persistence.in_memory_content_activity_repo;

// Use Cases
import application.usecases.manage_content_packages;
import application.usecases.manage_content_providers;
import application.usecases.manage_transport_requests;
import application.usecases.export_content;
import application.usecases.import_content;
import application.usecases.manage_transport_queues;
import application.usecases.monitor_activities;

// Controllers
import presentation.http.package_controller;
import presentation.http.provider_controller;
import presentation.http.transport_controller;
import presentation.http.export_controller;
import presentation.http.import_controller;
import presentation.http.queue_controller;
import presentation.http.activity_controller;
import presentation.http.health_controller;

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
    c.packageRepo = new InMemoryContentPackageRepository();
    c.providerRepo = new InMemoryContentProviderRepository();
    c.transportRequestRepo = new InMemoryTransportRequestRepository();
    c.exportJobRepo = new InMemoryExportJobRepository();
    c.importJobRepo = new InMemoryImportJobRepository();
    c.queueRepo = new InMemoryTransportQueueRepository();
    c.activityRepo = new InMemoryContentActivityRepository();

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
    c.healthController = new HealthController();

    return c;
}
