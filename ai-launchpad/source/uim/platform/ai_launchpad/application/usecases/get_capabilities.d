/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.get_capabilities;

import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

class GetCapabilitiesUseCase { // TODO: UIMUseCase {
  CapabilitiesResponse getCapabilities(TenantId tenantId) {
    CapabilitiesResponse r;
    r.tenantId = tenantId;
    r.serviceName = "AI Launchpad Service";
    r.apiVersion = "v1";
    r.serviceVersion = "1.0.0";
    r.supportedRuntimes = ["ai_core", "custom"];
    r.features = [
      "connection_management",
      "workspace_management",
      "scenario_browsing",
      "configuration_management",
      "execution_lifecycle",
      "deployment_lifecycle",
      "model_management",
      "dataset_management",
      "generative_ai_hub",
      "prompt_management",
      "prompt_collections",
      "resource_group_management",
      "usage_statistics",
      "bulk_operations"
    ];
    r.multiTenant = true;
    r.genAiHub = true;
    r.promptManagement = true;
    r.usageStatistics = true;
    r.bulkOperations = true;
    r.maxConnections = 50;
    return r;
  }
}

unittest {
  auto usecase = new GetCapabilitiesUseCase();
  auto tenantId = TenantId("tenant-a");

  auto result = usecase.getCapabilities(tenantId);

  assert(result.tenantId == tenantId);
  assert(result.apiVersion == "v1");
  assert(result.serviceName.length > 0);
  assert(result.supportedRuntimes.length > 0);
  assert(result.features.length > 0);
}
