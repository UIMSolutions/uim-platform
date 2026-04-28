/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.dto;

// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.domain.entities.content_package : ContentItem;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// --- Content Package DTOs ---

struct CreatePackageRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  string version_;
  string format; // "mtar", "zip", "json"
  ContentItem[] items;
  string[] tags;
  UserId createdBy;
}

struct UpdatePackageRequest {
  string description;
  string version_;
  ContentItem[] items;
  string[] tags;
}

struct AssemblePackageRequest {
  ContentPackageId packageId;
  TenantId tenantId;
  string assembledBy;
}

/// --- Content Provider DTOs ---

struct RegisterProviderRequest {
  TenantId tenantId;
  string name;
  string description;
  string endpoint;
  string authToken;
  string registeredBy;
}

struct UpdateProviderRequest {
  string description;
  string endpoint;
  string authToken;
}

/// --- Transport Request DTOs ---

struct CreateTransportRequest {
  TenantId tenantId;
  SubaccountId sourceSubaccount;
  SubaccountId targetSubaccount;
  string description;
  string mode; // "cloudTransportManagement", "ctsPlus", "directExport", "fileDownload"
  ContentPackageId[] packageIds;
  TransportQueueId queueId;
  UserId createdBy;
}

struct ReleaseTransportRequest {
  TransportRequestId requestId;
  TenantId tenantId;
  string releasedBy;
}

/// --- Export Job DTOs ---

struct StartExportRequest {
  TenantId tenantId;
  ContentPackageId packageId;
  TransportRequestId transportRequestId;
  TransportQueueId queueId;
  string startedBy;
}

/// --- Import Job DTOs ---

struct StartImportRequest {
  TenantId tenantId;
  ContentPackageId packageId;
  TransportRequestId transportRequestId;
  string sourceFilePath;
  string startedBy;
}

/// --- Transport Queue DTOs ---

struct CreateQueueRequest {
  TenantId tenantId;
  string name;
  string description;
  string queueType; // "cloudTMS", "ctsPlus", "local"
  string endpoint;
  string authToken;
  bool isDefault;
  UserId createdBy;
}

struct UpdateQueueRequest {
  string description;
  string endpoint;
  string authToken;
  bool isDefault;
}

/// --- Activity query ---

struct ActivityQuery {
  TenantId tenantId;
  string entityId;
  string activityType;
  int limit = 50;
}
