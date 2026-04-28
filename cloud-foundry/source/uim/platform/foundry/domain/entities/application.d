/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.application;

// import uim.platform.foundry.domain.types;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// A Cloud Foundry application — represents a deployed unit with scaling,
/// health checks, and environment configuration.
struct Application {
  mixin TenantEntity!AppId;

  SpaceId spaceId;
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
  long stagedAt;

  Json toJson() const {
    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("state", state.to!string)
      .set("instances", instances)
      .set("memoryMb", memoryMb)
      .set("diskMb", diskMb)
      .set("buildpackId", buildpackId)
      .set("detectedBuildpack", detectedBuildpack)
      .set("stack", stack)
      .set("command", command)
      .set("healthCheckType", healthCheckType.to!string)
      .set("healthCheckEndpoint", healthCheckEndpoint)
      .set("healthCheckTimeoutSec", healthCheckTimeoutSec)
      .set("environmentVariables", environmentVariables)
      .set("dockerImage", dockerImage)
      .set("dockerCredentials", dockerCredentials)
      .set("runningInstances", runningInstances)
      .set("stagedAt", stagedAt);

  }
}


