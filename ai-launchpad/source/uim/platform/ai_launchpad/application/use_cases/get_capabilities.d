/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.get_capabilities;

import uim.platform.ai_launchpad.application.dto;

class GetCapabilitiesUseCase : UIMUseCase {
  CapabilitiesResponse getbyId() {
    CapabilitiesResponse r;
    r.serviceName = "AI Launchpad Service";
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
