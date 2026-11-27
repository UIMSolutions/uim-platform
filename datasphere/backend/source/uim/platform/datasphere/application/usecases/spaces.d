/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Spaces and their members.
///
/// A space can only be deleted when it no longer contains connections,
/// remote tables, views, data flows, tasks, task chains, data access
/// controls or catalog assets; its members and runs are removed with it.
/// The disk quota cannot be lowered below the used disk.
module uim.platform.datasphere.application.usecases.spaces;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// GiB (API) → bytes (entity), rounded to MiB.
long gibToBytes(double gib) pure {
  return cast(long)(gib * 1024) * (bytesPerGiB / 1024);
}

double bytesToGib(long bytes) pure {
  return cast(double) bytes / bytesPerGiB;
}

class ManageSpacesUseCase : ResourceInteractor!(Space, SpaceId, SpaceInput), IManageSpaces {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(Space, SpaceId) store() {
    return repos.spaces;
  }

  protected override string what() {
    return "Space";
  }

  protected override string eventPrefix() {
    return "space";
  }

  protected override SpaceInput toInput(const Space e) {
    SpaceInput i;
    i.name = e.name;
    i.description = e.description;
    i.priority = e.priority;
    i.diskQuotaGiB = bytesToGib(e.diskQuotaBytes);
    i.memoryQuotaGiB = bytesToGib(e.memoryQuotaBytes);
    i.auditLogEnabled = e.auditLogEnabled;
    return i;
  }

  protected override void fromInput(TenantId t, ref Space e, SpaceInput i, bool creating) {
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.description = i.description.strip;
    e.priority = i.priority;
    e.diskQuotaBytes = gibToBytes(i.diskQuotaGiB);
    e.memoryQuotaBytes = gibToBytes(i.memoryQuotaGiB);
    e.auditLogEnabled = i.auditLogEnabled;
  }

  protected override void beforeSave(TenantId t, ref Space e, bool creating) {
    if (!creating && e.diskQuotaBytes < e.usedDiskBytes)
      throw DspException.ruleViolation(format("The disk quota cannot be lower than the used disk (%.2f GiB)",
          bytesToGib(e.usedDiskBytes)));
  }

  protected override void beforeRemove(TenantId t, const Space e, UserId actor) {
    auto s = e.id.value;
    long objects = repos.connections.countByReference(t, "spaceId", s) + repos.remoteTables.countByReference(t, "spaceId", s)
      + repos.views.countByReference(t, "spaceId", s) + repos.dataFlows.countByReference(t, "spaceId", s)
      + repos.tasks.countByReference(t, "spaceId", s) + repos.taskChains.countByReference(t, "spaceId", s)
      + repos.accessControls.countByReference(t, "spaceId", s) + repos.catalog.countByReference(t, "spaceId", s);
    requireUnused("Space '" ~ s ~ "'", objects, "objects (delete them first)");
    repos.members.removeByReference(t, "spaceId", s);
    repos.runs.removeByReference(t, "spaceId", s);
  }

  Space lock(TenantId t, SpaceId id, string reason, UserId actor) {
    auto s = get(t, id);
    s.status = SpaceStatus.locked;
    s.lockedReason = reason.strip.length ? reason.strip : "locked by " ~ actor.value;
    s.validate();
    stampUpdated(s, actor, now);
    repos.spaces.save(s);
    emit("space.locked", t, id.value, Json(["reason": Json(s.lockedReason)]));
    return s;
  }

  Space unlock(TenantId t, SpaceId id, UserId actor) {
    auto s = refreshUsage(t, id);
    if (s.usedDiskBytes > s.diskQuotaBytes)
      throw DspException.ruleViolation(format("Space '%s' uses %.2f GiB of %.2f GiB: raise the quota or free disk first",
          id.value, bytesToGib(s.usedDiskBytes), bytesToGib(s.diskQuotaBytes)));
    s.status = SpaceStatus.active;
    s.lockedReason = "";
    stampUpdated(s, actor, now);
    repos.spaces.save(s);
    emit("space.unlocked", t, id.value);
    return s;
  }

  Space refreshUsage(TenantId t, SpaceId id) {
    get(t, id);
    return runner.refreshUsage(t, id);
  }
}

class ManageMembersUseCase : ResourceInteractor!(SpaceMember, SpaceMemberId, MemberInput), IManageMembers {
  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IDspRepository!(SpaceMember, SpaceMemberId) store() {
    return repos.members;
  }

  protected override string what() {
    return "Member";
  }

  protected override string eventPrefix() {
    return "member";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId", "userName"];
  }

  protected override MemberInput toInput(const SpaceMember e) {
    MemberInput i;
    i.spaceId = e.spaceId.value;
    i.userName = e.userName;
    i.displayName = e.displayName;
    i.role = cast(string) e.role;
    return i;
  }

  protected override void fromInput(TenantId t, ref SpaceMember e, MemberInput i, bool creating) {
    if (creating)
      spaceOf(t, SpaceId(i.spaceId.strip));
    e.spaceId = SpaceId(i.spaceId.strip);
    e.userName = i.userName.strip;
    e.displayName = i.displayName.strip.length ? i.displayName.strip : e.userName;
    auto role = parseDomainEnum!SpaceRole(i.role, "space role");
    if (!creating && e.role == SpaceRole.administrator && role != SpaceRole.administrator)
      requireAnotherAdministrator(t, e);
    e.role = role;
  }

  protected void requireAnotherAdministrator(TenantId t, const SpaceMember e) {
    auto admins = repos.members.findByReference(t, "spaceId", e.spaceId.value)
      .count!(m => m.role == SpaceRole.administrator && m.id != e.id);
    if (admins == 0)
      throw DspException.ruleViolation("The last administrator of space '" ~ e.spaceId.value ~ "' cannot be removed");
  }

  protected override void beforeSave(TenantId t, ref SpaceMember e, bool creating) {
    if (!creating)
      return;
    foreach (m; repos.members.findByReference(t, "spaceId", e.spaceId.value))
      if (m.userName == e.userName)
        throw DspException.conflict("'" ~ e.userName ~ "' is already a member of space '" ~ e.spaceId.value ~ "'");
  }

  protected override void beforeRemove(TenantId t, const SpaceMember e, UserId actor) {
    if (e.role == SpaceRole.administrator)
      requireAnotherAdministrator(t, e);
  }
}
