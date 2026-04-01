module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.destination_repo;
import infrastructure.persistence.memory.connector_repo;
import infrastructure.persistence.memory.channel_repo;
import infrastructure.persistence.memory.access_rule_repo;
import infrastructure.persistence.memory.certificate_repo;
import infrastructure.persistence.memory.connectivity_log_repo;

// Use Cases
import application.usecases.manage_destinations;
import application.usecases.manage_connectors;
import application.usecases.manage_channels;
import application.usecases.manage_access_rules;
import application.usecases.manage_certificates;
import application.usecases.monitor_connectivity;

// Controllers
import presentation.http.destination;
import presentation.http.connector;
import presentation.http.channel;
import presentation.http.access_rule;
import presentation.http.certificate;
import presentation.http.monitoring;
import presentation.http.health;

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
