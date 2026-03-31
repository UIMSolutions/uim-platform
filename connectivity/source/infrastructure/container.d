module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_destination_repo;
import infrastructure.persistence.in_memory_connector_repo;
import infrastructure.persistence.in_memory_channel_repo;
import infrastructure.persistence.in_memory_access_rule_repo;
import infrastructure.persistence.in_memory_certificate_repo;
import infrastructure.persistence.in_memory_connectivity_log_repo;

// Use Cases
import application.usecases.manage_destinations;
import application.usecases.manage_connectors;
import application.usecases.manage_channels;
import application.usecases.manage_access_rules;
import application.usecases.manage_certificates;
import application.usecases.monitor_connectivity;

// Controllers
import presentation.http.destination_controller;
import presentation.http.connector_controller;
import presentation.http.channel_controller;
import presentation.http.access_rule_controller;
import presentation.http.certificate_controller;
import presentation.http.monitoring_controller;
import presentation.http.health_controller;

/// Dependency injection container - wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryDestinationRepository destinationRepo;
    InMemoryConnectorRepository connectorRepo;
    InMemoryChannelRepository channelRepo;
    InMemoryAccessRuleRepository accessRuleRepo;
    InMemoryCertificateRepository certificateRepo;
    InMemoryConnectivityLogRepository logRepo;

    // Use cases (application layer)
    ManageDestinationsUseCase manageDestinations;
    ManageConnectorsUseCase manageConnectors;
    ManageChannelsUseCase manageChannels;
    ManageAccessRulesUseCase manageAccessRules;
    ManageCertificatesUseCase manageCertificates;
    MonitorConnectivityUseCase monitorConnectivity;

    // Controllers (driving adapters)
    DestinationController destinationController;
    ConnectorController connectorController;
    ChannelController channelController;
    AccessRuleController accessRuleController;
    CertificateController certificateController;
    MonitoringController monitoringController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.destinationRepo = new InMemoryDestinationRepository();
    c.connectorRepo = new InMemoryConnectorRepository();
    c.channelRepo = new InMemoryChannelRepository();
    c.accessRuleRepo = new InMemoryAccessRuleRepository();
    c.certificateRepo = new InMemoryCertificateRepository();
    c.logRepo = new InMemoryConnectivityLogRepository();

    // Application use cases
    c.manageDestinations = new ManageDestinationsUseCase(c.destinationRepo, c.logRepo);
    c.manageConnectors = new ManageConnectorsUseCase(c.connectorRepo, c.logRepo);
    c.manageChannels = new ManageChannelsUseCase(c.channelRepo, c.connectorRepo, c.logRepo);
    c.manageAccessRules = new ManageAccessRulesUseCase(c.accessRuleRepo, c.connectorRepo);
    c.manageCertificates = new ManageCertificatesUseCase(c.certificateRepo);
    c.monitorConnectivity = new MonitorConnectivityUseCase(c.logRepo);

    // Presentation controllers
    c.destinationController = new DestinationController(c.manageDestinations);
    c.connectorController = new ConnectorController(c.manageConnectors);
    c.channelController = new ChannelController(c.manageChannels);
    c.accessRuleController = new AccessRuleController(c.manageAccessRules);
    c.certificateController = new CertificateController(c.manageCertificates);
    c.monitoringController = new MonitoringController(c.monitorConnectivity);
    c.healthController = new HealthController();

    return c;
}
