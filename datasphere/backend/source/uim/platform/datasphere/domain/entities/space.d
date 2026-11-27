/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A space: the isolated workspace of a team with its own disk and memory
/// quota, members, connections and models. The id is the technical space
/// name (e.g. "SALES").
module uim.platform.datasphere.domain.entities.space;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum long bytesPerGiB = 1L << 30;
enum long minQuotaBytes = bytesPerGiB / 4; /// 256 MiB
enum long maxQuotaBytes = 64L * 1024 * bytesPerGiB; /// 64 TiB

struct Space {
  mixin TenantEntity!SpaceId;

  string name; /// business name
  string description;
  SpaceStatus status = SpaceStatus.active;
  int priority = 5; /// workload priority 1 (lowest) .. 8 (highest)
  long diskQuotaBytes = 10 * bytesPerGiB;
  long memoryQuotaBytes = 2 * bytesPerGiB;
  long usedDiskBytes; /// replicated tables, persisted views, data flow targets
  bool auditLogEnabled;
  string lockedReason;

  bool isActive() const {
    return status == SpaceStatus.active;
  }

  /// Used disk in percent of the quota (0..; > 100 when over quota).
  double diskUsagePercent() const {
    return diskQuotaBytes > 0 ? 100.0 * usedDiskBytes / diskQuotaBytes : 0;
  }

  /// True if the space can take the additional bytes.
  bool fits(long additionalBytes) const {
    return usedDiskBytes + additionalBytes <= diskQuotaBytes;
  }

  /// Refuse work in a locked space.
  void requireActive(string operation) const {
    if (!isActive)
      throw DspException.ruleViolation("Space '" ~ id.value ~ "' is locked" ~ (lockedReason.length ? " (" ~ lockedReason ~ ")"
          : "") ~ ": " ~ operation ~ " is not possible");
  }

  void validate() const {
    requireId(id.value, "Space ID");
    requireText(name, "Space name");
    requireMaxLength(name, 200, "Space name");
    requireMaxLength(description, 2000, "Description");
    requireMaxLength(lockedReason, 500, "Lock reason");
    requireRange(priority, 1, 8, "Priority");
    requireRange(diskQuotaBytes, minQuotaBytes, maxQuotaBytes, "Disk quota (bytes)");
    requireRange(memoryQuotaBytes, minQuotaBytes, maxQuotaBytes, "Memory quota (bytes)");
    if (memoryQuotaBytes > diskQuotaBytes)
      throw DspException.invalid("The memory quota must not exceed the disk quota");
  }
}

///
unittest {
  Space s;
  s.id = SpaceId("SALES");
  s.name = "Sales";
  s.validate();
  assert(s.isActive && s.fits(bytesPerGiB) && !s.fits(11 * bytesPerGiB));
  s.usedDiskBytes = 5 * bytesPerGiB;
  assert(s.diskUsagePercent > 49.9 && s.diskUsagePercent < 50.1);
  s.memoryQuotaBytes = 20 * bytesPerGiB;
  assert(failsWith(DspErrorKind.invalid, () { s.validate(); }));
  s.memoryQuotaBytes = bytesPerGiB;
  s.status = SpaceStatus.locked;
  assert(failsWith(DspErrorKind.ruleViolation, () { s.requireActive("Replication"); }));
}
