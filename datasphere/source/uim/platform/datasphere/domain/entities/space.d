/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.space;

import uim.platform.datasphere.domain.types;

struct SpaceLabel {
  string key;
  string value;
}

struct StorageAssignment {
  StorageType type;
  long quotaBytes;
  long usedBytes;
}

struct SpaceMember {
  string userId;
  string role;
}

struct Space {
  SpaceId id;
  TenantId tenantId;
  string name;
  string description;
  string businessName;
  StorageAssignment[] storage;
  SpaceMember[] members;
  SpaceLabel[] labels;
  int priority;
  bool enableAuditLog;
  long createdAt;
  long modifiedAt;
}
