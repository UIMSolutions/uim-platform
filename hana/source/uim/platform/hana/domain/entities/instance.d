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

  Json toJson() const {
    return Json.emptyObject()
      .set("host", host)
      .set("port", port)
      .set("protocol", protocol);
  }
}

struct InstanceResource {
  long memoryGB;
  int vcpus;
  long storageGB;
  long usedStorageGB;

  Json toJson() const {
    return Json.emptyObject()
      .set("memoryGB", memoryGB)
      .set("vcpus", vcpus)
      .set("storageGB", storageGB)
      .set("usedStorageGB", usedStorageGB);
  }
}

struct InstanceLabel {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject()
      .set("key", key)
      .set("value", value);
  }
}

struct DatabaseInstance {
  mixin TenantEntity!(InstanceId);

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
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("type", type.toString())
      .set("status", status.toString())
      .set("size", size.toString())
      .set("version", version_)
      .set("region", region)
      .set("availabilityZone", availabilityZone)
      .set("endpoint", endpoint.toJson())
      .set("resources", resources.toJson())
      .set("labels", labels.map!(l => l.toJson()).array)
      .set("enableScriptServer", enableScriptServer)
      .set("enableDocStore", enableDocStore)
      .set("enableDataLake", enableDataLake)
      .set("allowAllIpAccess", allowAllIpAccess)
      .set("whitelistedIps", whitelistedIps.array);
  }
}
