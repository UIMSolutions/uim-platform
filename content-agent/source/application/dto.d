module uim.platform.content_agent.application.dto;

import domain.types;
import domain.entities.content_package : ContentItem;

/// --- Command result ---

struct CommandResult
{
    bool success;
    string id;
    string error;
}

/// --- Content Package DTOs ---

struct CreatePackageRequest
{
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    string version_;
    string format;          // "mtar", "zip", "json"
    ContentItem[] items;
    string[] tags;
    string createdBy;
}

struct UpdatePackageRequest
{
    string description;
    string version_;
    ContentItem[] items;
    string[] tags;
}

struct AssemblePackageRequest
{
    ContentPackageId packageId;
    TenantId tenantId;
    string assembledBy;
}

/// --- Content Provider DTOs ---

struct RegisterProviderRequest
{
    TenantId tenantId;
    string name;
    string description;
    string endpoint;
    string authToken;
    string registeredBy;
}

struct UpdateProviderRequest
{
    string description;
    string endpoint;
    string authToken;
}

/// --- Transport Request DTOs ---

struct CreateTransportRequest
{
    TenantId tenantId;
    SubaccountId sourceSubaccount;
    SubaccountId targetSubaccount;
    string description;
    string mode;            // "cloudTransportManagement", "ctsPlus", "directExport", "fileDownload"
    ContentPackageId[] packageIds;
    TransportQueueId queueId;
    string createdBy;
}

struct ReleaseTransportRequest
{
    TransportRequestId requestId;
    TenantId tenantId;
    string releasedBy;
}

/// --- Export Job DTOs ---

struct StartExportRequest
{
    TenantId tenantId;
    ContentPackageId packageId;
    TransportRequestId transportRequestId;
    TransportQueueId queueId;
    string startedBy;
}

/// --- Import Job DTOs ---

struct StartImportRequest
{
    TenantId tenantId;
    ContentPackageId packageId;
    TransportRequestId transportRequestId;
    string sourceFilePath;
    string startedBy;
}

/// --- Transport Queue DTOs ---

struct CreateQueueRequest
{
    TenantId tenantId;
    string name;
    string description;
    string queueType;       // "cloudTMS", "ctsPlus", "local"
    string endpoint;
    string authToken;
    bool isDefault;
    string createdBy;
}

struct UpdateQueueRequest
{
    string description;
    string endpoint;
    string authToken;
    bool isDefault;
}

/// --- Activity query ---

struct ActivityQuery
{
    TenantId tenantId;
    string entityId;
    string activityType;
    int limit = 50;
}
