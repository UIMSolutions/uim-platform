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
}

struct DataLakeStorage {
  StorageTier tier;
  long capacityGB;
  long usedGB;
}

struct DataLake {
  DataLakeId id;
  TenantId tenantId;
  InstanceId instanceId;
  string name;
  string description;
  DataLakeStatus status;
  DataLakeEndpoint endpoint;
  DataLakeStorage[] storage;
  FileFormat[] supportedFormats;
  int computeNodes;
  long createdAt;
  long modifiedAt;
}
