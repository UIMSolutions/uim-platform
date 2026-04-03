module uim.platform.cloud_foundry.domain.entities.application;

import uim.platform.cloud_foundry.domain.types;

/// A Cloud Foundry application — represents a deployed unit with scaling,
/// health checks, and environment configuration.
struct Application {
  AppId id;
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  AppState state = AppState.stopped;
  int instances = 1;
  int memoryMb = 256;
  int diskMb = 1024;
  BuildpackId buildpackId;
  string detectedBuildpack;
  string stack = "cflinuxfs4";
  string command; // custom start command
  HealthCheckType healthCheckType = HealthCheckType.port;
  string healthCheckEndpoint = "/";
  int healthCheckTimeoutSec = 60;
  string environmentVariables; // JSON string of user-provided env vars
  string dockerImage;
  string dockerCredentials;
  int runningInstances; // actual running instance count
  string createdBy;
  long createdAt;
  long updatedAt;
  long stagedAt;
}
