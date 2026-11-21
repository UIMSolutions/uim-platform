/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// fields under their D names. Records below a resource group are stored
/// under the key "<resourceGroupId>~<id>". Secrets are fingerprints only.
module uim.platform.ai_core.persistence.records.collections;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum Collections : string {
  resourceGroups = "aicore.resourceGroups",
  scenarios = "aicore.scenarios",
  executables = "aicore.executables",
  configurations = "aicore.configurations",
  executions = "aicore.executions",
  deployments = "aicore.deployments",
  artifacts = "aicore.artifacts",
  schedules = "aicore.executionSchedules",
  metrics = "aicore.metrics",
  dockerSecrets = "aicore.dockerRegistrySecrets",
  objectStoreSecrets = "aicore.objectStoreSecrets"
}
