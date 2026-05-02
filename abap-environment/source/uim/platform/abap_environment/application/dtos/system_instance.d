module uim.platform.abap_environment.application.dtos.system_instance;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
struct CreateSystemInstanceRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  string plan; // "standard", "free_", "development", "test", "production"
  string region;
  string sapSystemId; // 3-char SID
  string adminEmail;
  ushort abapRuntimeSize;
  ushort hanaMemorySize;
  string softwareVersion;
  string stackVersion;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("subaccountId", subaccountId.value)
      .set("name", name)
      .set("description", description)
      .set("plan", plan)
      .set("region", region)
      .set("sapSystemId", sapSystemId)
      .set("adminEmail", adminEmail)
      .set("abapRuntimeSize", abapRuntimeSize)
      .set("hanaMemorySize", hanaMemorySize)
      .set("softwareVersion", softwareVersion)
      .set("stackVersion", stackVersion);
  }
}

struct UpdateSystemInstanceRequest {
  string description;
  string status; // lifecycle transition target
  ushort abapRuntimeSize;
  ushort hanaMemorySize;
  string softwareVersion;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("status", status)
      .set("abapRuntimeSize", abapRuntimeSize)
      .set("hanaMemorySize", hanaMemorySize)
      .set("softwareVersion", softwareVersion);
  }
}