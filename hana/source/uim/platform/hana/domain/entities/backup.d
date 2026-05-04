/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.backup;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct BackupSchedule {
  string cronExpression;
  int retentionDays;
  bool enabled;

  Json toJson() const {
    return Json.emptyObject
      .set("cronExpression", cronExpression)
      .set("retentionDays", retentionDays)
      .set("enabled", enabled);
  }
}

struct Backup {
  mixin TenantEntity!(BackupId);

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
  
  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId.value)
      .set("name", name)
      .set("type", type.toString())
      .set("status", status.toString())
      .set("sizeBytes", sizeBytes)
      .set("destination", destination)
      .set("encryptionKey", encryptionKey)
      .set("encrypted", encrypted)
      .set("schedule", schedule.toJson())
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("expiresAt", expiresAt);
  }
}
