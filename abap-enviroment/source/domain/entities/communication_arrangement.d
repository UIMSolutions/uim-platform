module domain.entities.communication_arrangement;

import domain.types;

/// Inbound/outbound communication endpoint configuration.
struct CommunicationEndpoint
{
    string url;
    CommunicationProtocol protocol = CommunicationProtocol.httpRest;
    ushort port;
    bool active = true;
}

/// Communication arrangement linking scenario, system, and credentials.
struct CommunicationArrangement
{
    CommunicationArrangementId id;
    TenantId tenantId;
    SystemInstanceId systemInstanceId;
    CommunicationScenarioId scenarioId;
    string name;
    string description;

    CommunicationDirection direction = CommunicationDirection.inbound;
    ArrangementStatus status = ArrangementStatus.active;

    /// Authentication
    CommunicationAuthMethod authMethod = CommunicationAuthMethod.basicAuthentication;
    string communicationUser;
    string communicationPassword;
    string clientId;
    string clientSecret;
    string tokenEndpoint;
    string certificateId;

    /// Endpoints
    CommunicationEndpoint[] inboundServices;
    CommunicationEndpoint[] outboundServices;

    /// Metadata
    string createdBy;
    long createdAt;
    long updatedAt;
}
