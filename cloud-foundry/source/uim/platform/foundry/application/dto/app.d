module uim.platform.foundry.application.dto.app;
 import uim.platform.foundry;

// mixin(ShowModule!());

@safe:

struct CreateAppRequest {
  SpaceId spaceId;
  TenantId tenantId;
  AppId appId;

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
  TenantId tenantId;
  AppId appId;
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
  AppId appId;
  TenantId tenantId;
  
  int instances;
  int memoryMb;
  int diskMb;
}