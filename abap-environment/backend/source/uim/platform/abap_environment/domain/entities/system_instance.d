/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.system_instance;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A provisioned ABAP environment (ABAP Cloud system). Root of all other aggregates.
struct SystemInstance {
  mixin TenantEntity!SystemInstanceId;

  SubaccountId subaccountId;
  string name;
  string description;
  SystemPlan plan = SystemPlan.standard;
  SystemStatus status = SystemStatus.provisioning;
  string statusMessage;

  // Sizing and region
  string region = "eu10";
  string sapSystemId; /// three character SID, e.g. "H01"
  string adminEmail;
  int abapRuntimeSize = 16; /// GB (1 ABAP compute unit = 16 GB)
  int hanaMemorySize = 64; /// GB

  // Connectivity (set when provisioning completes)
  string serviceUrl;
  string webSocketUrl;
  string sapClient = "100";

  // Software stack
  string softwareVersion = "2511";
  string stackVersion;
  long activatedAt;
}
