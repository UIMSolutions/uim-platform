/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.backup;

import uim.platform.hana.domain.types;

struct BackupSchedule {
  string cronExpression;
  int retentionDays;
  bool enabled;
}

struct Backup {
  BackupId id;
  TenantId tenantId;
  InstanceId instanceId;
  string name;
  BackupType type;
  BackupStatus status;
  long sizeBytes;
  string destination;
  string encryptionKey;
  bool encrypted;
  BackupSchedule schedule;
  long startedAt;
  long completedAt;
  long expiresAt;
  long createdAt;
}
