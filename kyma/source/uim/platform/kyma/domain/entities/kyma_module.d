/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.kyma_module;

import uim.platform.kyma.domain.types;

/// A Kyma module — an optional component that can be enabled/disabled.
struct KymaModule
{
  ModuleId id;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  ModuleType moduleType = ModuleType.custom;
  ModuleStatus status = ModuleStatus.disabled;

  // Version info
  string version_;
  string channel;

  // Custom resource definition
  string customResourcePolicy;
  string configurationJson;

  // Dependencies — other modules that must be enabled
  string[] requiredModules;

  // Metadata
  string enabledBy;
  long enabledAt;
  long modifiedAt;
}
