module uim.platform.foundry.application.dto.app;
 import uim.platform.foundry;

// mixin(ShowModule!());

@safe:

struct CreateAppRequest {
  SpaceId spaceId;
  TenantId tenantId;
  UserId createdBy;

  string name;
  int instances;
  int memoryMb;
  int diskMb;
  string buildpackId;
  string stack;
  string command;
  string healthCheckType;
  string healthCheckEndpoint;
  int healthCheckTimeoutSec;
  string environmentVariables;
  string dockerImage;
}

struct UpdateAppRequest {
  AppId id;
  TenantId tenantId;
  string name;
  int instances;
  int memoryMb;
  int diskMb;
  string buildpackId;
  string stack;
  string command;
  string healthCheckType;
  string healthCheckEndpoint;
  int healthCheckTimeoutSec;
  string environmentVariables;
  string dockerImage;
}

struct ScaleAppRequest {
  AppId id;
  TenantId tenantId;
  
  int instances;
  int memoryMb;
  int diskMb;
}