module application.dto;

import domain.types;

// ──────────────── Organization DTOs ────────────────

struct CreateOrgRequest
{
  TenantId tenantId;
  string name;
  int memoryQuotaMb;
  int instanceMemoryLimitMb;
  int totalRoutes;
  int totalServices;
  int totalAppInstances;
  string createdBy;
}

struct UpdateOrgRequest
{
  OrgId id;
  TenantId tenantId;
  string name;
  OrgStatus status;
  int memoryQuotaMb;
  int instanceMemoryLimitMb;
  int totalRoutes;
  int totalServices;
  int totalAppInstances;
}

// ──────────────── Space DTOs ────────────────

struct CreateSpaceRequest
{
  OrgId orgId;
  TenantId tenantId;
  string name;
  bool allowSsh;
  string createdBy;
}

struct UpdateSpaceRequest
{
  SpaceId id;
  TenantId tenantId;
  string name;
  SpaceStatus status;
  bool allowSsh;
}

// ──────────────── Application DTOs ────────────────

struct CreateAppRequest
{
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  int instances;
  int memoryMb;
  int diskMb;
  string buildpackId;
  string stack;
  string command;
  HealthCheckType healthCheckType;
  string healthCheckEndpoint;
  int healthCheckTimeoutSec;
  string environmentVariables;
  string dockerImage;
  string createdBy;
}

struct UpdateAppRequest
{
  AppId id;
  TenantId tenantId;
  string name;
  int instances;
  int memoryMb;
  int diskMb;
  string buildpackId;
  string stack;
  string command;
  HealthCheckType healthCheckType;
  string healthCheckEndpoint;
  int healthCheckTimeoutSec;
  string environmentVariables;
  string dockerImage;
}

struct ScaleAppRequest
{
  AppId id;
  TenantId tenantId;
  int instances;
  int memoryMb;
  int diskMb;
}

// ──────────────── Service Instance DTOs ────────────────

struct CreateServiceInstanceRequest
{
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  string serviceName;
  string servicePlanName;
  string parameters;
  string tags;
  string createdBy;
}

struct UpdateServiceInstanceRequest
{
  ServiceInstanceId id;
  TenantId tenantId;
  string name;
  string servicePlanName;
  string parameters;
  string tags;
}

// ──────────────── Service Binding DTOs ────────────────

struct CreateServiceBindingRequest
{
  AppId appId;
  ServiceInstanceId serviceInstanceId;
  TenantId tenantId;
  string name;
  string bindingOptions;
  string createdBy;
}

// ──────────────── Route DTOs ────────────────

struct CreateRouteRequest
{
  SpaceId spaceId;
  DomainId domainId;
  TenantId tenantId;
  string host;
  string path;
  int port;
  RouteProtocol protocol;
  string createdBy;
}

struct MapRouteRequest
{
  RouteId routeId;
  AppId appId;
  TenantId tenantId;
}

// ──────────────── Domain DTOs ────────────────

struct CreateDomainRequest
{
  OrgId ownerOrgId;
  TenantId tenantId;
  string name;
  DomainScope scope_;
  bool isInternal;
  string createdBy;
}

// ──────────────── Buildpack DTOs ────────────────

struct CreateBuildpackRequest
{
  TenantId tenantId;
  string name;
  BuildpackType type_;
  int position;
  string stack;
  string filename;
  string createdBy;
}

struct UpdateBuildpackRequest
{
  BuildpackId id;
  TenantId tenantId;
  string name;
  int position;
  string stack;
  string filename;
  bool enabled;
  bool locked;
}

// ──────────────── Generic result ────────────────

struct CommandResult
{
  string id;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}
