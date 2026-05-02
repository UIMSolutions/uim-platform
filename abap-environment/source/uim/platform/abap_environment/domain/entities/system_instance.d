/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.system_instance;

// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Provisioned ABAP Cloud system instance.
struct SystemInstance {
  mixin TenantEntity!(SystemInstanceId);

  SubaccountId subaccountId;
  string name;
  string description;
  SystemPlan plan = SystemPlan.standard;
  SystemStatus status = SystemStatus.provisioning;

  /// Runtime parameters
  string region;
  string sapSystemId; // 3-char SID
  string adminEmail;
  ushort abapRuntimeSize; // in GB
  ushort hanaMemorySize; // in GB

  /// Connectivity
  string serviceUrl;
  string webSocketUrl;
  string sapClient;

  /// Software stack
  string softwareVersion;
  string stackVersion;

  Json toJson() const {
    return entityToJson
      .set("subaccountId", subaccountId)
      .set("name", name)
      .set("description", description)
      .set("plan", plan.to!string)
      .set("status", status.to!string)
      .set("region", region)
      .set("sapSystemId", sapSystemId)
      .set("adminEmail", adminEmail)
      .set("abapRuntimeSize", abapRuntimeSize)
      .set("hanaMemorySize", hanaMemorySize)
      .set("serviceUrl", serviceUrl)
      .set("webSocketUrl", webSocketUrl)
      .set("sapClient", sapClient)
      .set("softwareVersion", softwareVersion)
      .set("stackVersion", stackVersion);
  }
}
