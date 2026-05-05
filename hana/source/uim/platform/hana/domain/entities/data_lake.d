/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.data_lake;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct DataLakeEndpoint {
  string host;
  int port;
  string coordinator;

  Json toJson() const {
      return Json.emptyObject
          .set("host", host)
          .set("port", port)
          .set("coordinator", coordinator);
  }
}

struct DataLakeStorage {
  StorageTier tier;
  long capacityGB;
  long usedGB;

  Json toJson() const {
      return Json.emptyObject
          .set("tier", tier.to!string)
          .set("capacityGB", capacityGB)
          .set("usedGB", usedGB);
  }
}

struct DataLake {
  mixin TenantEntity!(DataLakeId);

  DatabaseInstanceId instanceId;
  string name;
  string description;
  DataLakeStatus status;
  DataLakeEndpoint endpoint;
  DataLakeStorage[] storage;
  FileFormat[] supportedFormats;
  int computeNodes;
  
  Json toJson() const {
      return entityToJson
          .set("instanceId", instanceId.value)
          .set("name", name)
          .set("description", description)
          .set("status", status.to!string)
          .set("endpoint", endpoint.toJson())
          .set("storage", storage.map!(s => s.toJson()).array)
          .set("supportedFormats", supportedFormats.map!(f => f.to!string).array)
          .set("computeNodes", computeNodes);
  }
}
