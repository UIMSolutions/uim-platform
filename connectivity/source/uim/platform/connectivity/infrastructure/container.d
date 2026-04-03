module uim.platform.connectivity.infrastructure.container;

import uim.platform.connectivity.infrastructure.config;

// Repositories
import uim.platform.connectivity.infrastructure.persistence.memory.destination_repo;
import uim.platform.connectivity.infrastructure.persistence.memory.connector_repo;
import uim.platform.connectivity.infrastructure.persistence.memory.channel_repo;
import uim.platform.connectivity.infrastructure.persistence.memory.access_rule_repo;
import uim.platform.connectivity.infrastructure.persistence.memory.certificate_repo;
import uim.platform.connectivity.infrastructure.persistence.memory.connectivity_log_repo;

// Use Cases
import uim.platform.connectivity.application.usecases.manage_destinations;
import uim.platform.connectivity.application.usecases.manage_connectors;
import uim.platform.connectivity.application.usecases.manage_channels;
import uim.platform.connectivity.application.usecases.manage_access_rules;
import uim.platform.connectivity.application.usecases.manage_certificates;
import uim.platform.connectivity.application.usecases.monitor_connectivity;

// Controllers
import uim.platform.connectivity.presentation.http.destination;
import uim.platform.connectivity.presentation.http.connector;
import uim.platform.connectivity.presentation.http.channel;
import uim.platform.connectivity.presentation.http.access_rule;
import uim.platform.connectivity.presentation.http.certificate;
import uim.platform.connectivity.presentation.http.monitoring;
import uim.platform.connectivity.presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container {
    // Repositories (driven adapters)
    MemoryDestinationRepository destinationRepo;
    MemoryConnectorRepository connectorRepo;
    MemoryChannelRepository channelRepo;
    MemoryAccessRuleRepository accessRuleRepo;
    MemoryCertificateRepository certificateRepo;
    MemoryConnectivityLogRepository logRepo;

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
Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.destinationRepo = new MemoryDestinationRepository();
    c.connectorRepo = new MemoryConnectorRepository();
    c.channelRepo = new MemoryChannelRepository();
    c.accessRuleRepo = new MemoryAccessRuleRepository();
    c.certificateRepo = new MemoryCertificateRepository();
    c.logRepo = new MemoryConnectivityLogRepository();

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
    c.healthController = new HealthController("connectivity");

    return c;
}
