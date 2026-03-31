module domain.entities.application;

import domain.types;

/// An external application connected to the Kyma environment.
struct Application
{
    ApplicationId id;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    AppConnectivityStatus status = AppConnectivityStatus.disconnected;
    AppRegistrationType registrationType = AppRegistrationType.apiAndEvents;

    // Connectivity
    string connectorUrl;
    string accessLabel;

    // Registered APIs
    AppApiEntry[] apis;

    // Registered event types
    AppEventEntry[] events;

    // Bound namespaces
    string[] boundNamespaces;

    // Labels
    string[string] labels;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}

/// An API entry registered by an external application.
struct AppApiEntry
{
    string name;
    string description;
    string targetUrl;
    string specUrl;
    string authType;
}

/// An event type registered by an external application.
struct AppEventEntry
{
    string name;
    string description;
    string version_;
}
