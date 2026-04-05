/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.instance;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct InstanceEndpoint {
  string host;
  int port;
  string protocol;
}

struct InstanceResource {
  long memoryGB;
  int vcpus;
  long storageGB;
  long usedStorageGB;
}

struct InstanceLabel {
  string key;
  string value;
}

struct DatabaseInstance {
  InstanceId id;
  TenantId tenantId;
  string name;
  string description;
  InstanceType type;
  InstanceStatus status;
  InstanceSize size;
  string version_;
  string region;
  string availabilityZone;
  InstanceEndpoint endpoint;
  InstanceResource resources;
  InstanceLabel[] labels;
  bool enableScriptServer;
  bool enableDocStore;
  bool enableDataLake;
  bool allowAllIpAccess;
  string[] whitelistedIps;
  long createdAt;
  long modifiedAt;
}
