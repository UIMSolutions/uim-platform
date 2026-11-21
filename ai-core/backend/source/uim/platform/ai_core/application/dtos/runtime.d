/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests of the runtime use cases.
module uim.platform.ai_core.application.dtos.runtime;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct CreateExecutionRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string configurationId;
  Label[] tags;
}

struct PatchExecutionRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  string targetStatus;
}

struct CreateDeploymentRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string configurationId;
  long ttlSeconds; /// 0 = unlimited
}

struct PatchDeploymentRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  string targetStatus; /// "" = keep
  string configurationId; /// "" = keep
}

struct CreateScheduleRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id; /// optional; generated if empty
  string name;
  string configurationId;
  string cron;
  string status = "ACTIVE";
  long startTime;
  long endTime;
}

struct UpdateScheduleRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  Patch!string name;
  Patch!string cron;
  Patch!string status;
  Patch!long startTime;
  Patch!long endTime;
}

/// One metric value of a LogMetricsRequest.
struct MetricInput {
  string name;
  double value = 0;
  long step;
  long timestamp; /// 0 = now
  Label[] labels;
}

struct LogMetricsRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string executionId;
  MetricInput[] metrics;
  Label[] tags; /// merged into the execution's tags
}
