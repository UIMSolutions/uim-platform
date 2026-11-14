/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.sync_sessions;

import core.time : minutes;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageSyncSessionsUseCase : IManageSyncSessionsUseCase {
  protected ISyncSessionRepository repo;
  protected IDeviceRepository devices;
  protected IAgentryEventPublisher events;

  /// devices may be null (no device checks / updates).
  this(ISyncSessionRepository repo, IDeviceRepository devices = null, IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.devices = devices;
    this.events = events is null ? new NullEventPublisher : events;
  }

  SyncSession[] listSyncSessions(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  SyncSession[] listByDevice(TenantId tenantId, DeviceId deviceId) {
    return repo.findByDevice(tenantId, deviceId);
  }

  SyncSession[] listByStatus(TenantId tenantId, SyncStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  SyncSession getSyncSession(TenantId tenantId, SyncSessionId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createSyncSession(SyncSessionDTO dto) {
    return guarded(() {
      if (!dto.sessionId.isNull && repo.existsById(dto.tenantId, dto.sessionId))
        return conflict("Sync session '" ~ dto.sessionId.value ~ "' already exists");

      auto session = newEntity!(SyncSession)(dto.tenantId, dto.sessionId, dto.createdBy);
      session.deviceId = dto.deviceId;
      session.applicationId = dto.applicationId;
      session.connectionId = dto.connectionId;
      session.triggeredBy = dto.triggeredBy.isNull ? dto.createdBy : dto.triggeredBy;
      session.clientAppVersion = dto.clientAppVersion;
      session.status = SyncStatus.pending;

      string[] errors;
      readEnum(dto.direction, session.direction, "direction", errors);
      if (dto.status.length > 0 && dto.status != "pending")
        errors ~= "new sync sessions start as pending — use startSyncSession";
      errors ~= AgentryValidator.validate(session);
      if (errors.length)
        return invalid(errors);

      if (devices !is null) {
        auto device = devices.findById(dto.tenantId, dto.deviceId);
        if (device.isNull)
          return rejected("Device '" ~ dto.deviceId.value ~ "' is not enrolled");
        if (device.status == DeviceStatus.suspended || device.status == DeviceStatus.removed)
          return rejected("Device '" ~ device.deviceName ~ "' is " ~ enumValue(device.status) ~ " and may not synchronize");
      }

      repo.save(session);
      return created(session.id.value, "Sync session created");
    });
  }

  UsecaseResult updateSyncSession(SyncSessionDTO dto) {
    return guarded(() {
      auto session = repo.findById(dto.tenantId, dto.sessionId);
      if (session.isNull)
        return notFound("Sync session", dto.sessionId.value);

      string[] errors;
      SyncStatus status = session.status;
      readEnum(dto.status, status, "status", errors);
      readEnum(dto.direction, session.direction, "direction", errors);
      if (errors.length)
        return invalid(errors);
      assignIf(session.clientAppVersion, dto.clientAppVersion);
      transition(session, status);

      touch(session, dto.updatedBy);
      repo.update(session);
      return succeeded(session.id.value, "Sync session updated");
    });
  }

  UsecaseResult startSyncSession(TenantId tenantId, SyncSessionId id) {
    return change(tenantId, id, (ref SyncSession s) { transition(s, SyncStatus.inProgress); }, "Sync session started");
  }

  UsecaseResult completeSyncSession(TenantId tenantId, SyncSessionId id, SyncMetricsDTO metrics) {
    if (metrics.bytesSent < 0 || metrics.bytesReceived < 0 || metrics.recordsSent < 0 || metrics.recordsReceived < 0)
      return invalid("transfer figures must not be negative");
    auto result = change(tenantId, id, (ref SyncSession s) {
      transition(s, SyncStatus.completed);
      s.bytesSent = metrics.bytesSent;
      s.bytesReceived = metrics.bytesReceived;
      s.recordsSent = metrics.recordsSent;
      s.recordsReceived = metrics.recordsReceived;
    }, "Sync session completed");
    if (result.isSuccess) {
      auto session = repo.findById(tenantId, id);
      markDeviceSeen(session);
      events.publish(AgentryTopics.syncCompleted, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value).set("deviceId", session.deviceId.value)
          .set("bytes", session.bytesSent + session.bytesReceived)
          .set("records", session.recordsSent + session.recordsReceived));
    }
    return result;
  }

  UsecaseResult failSyncSession(TenantId tenantId, SyncSessionId id, string errorMessage) {
    auto result = change(tenantId, id, (ref SyncSession s) {
      transition(s, SyncStatus.failed);
      s.errorMessage = errorMessage.length ? errorMessage : "Synchronization failed";
    }, "Sync session failed");
    if (result.isSuccess)
      events.publish(AgentryTopics.syncFailed, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value).set("error", errorMessage));
    return result;
  }

  UsecaseResult cancelSyncSession(TenantId tenantId, SyncSessionId id) {
    return change(tenantId, id, (ref SyncSession s) { transition(s, SyncStatus.cancelled); }, "Sync session cancelled");
  }

  UsecaseResult expireStaleSessions(TenantId tenantId, int timeoutMinutes) {
    if (timeoutMinutes <= 0)
      return invalid("timeoutMinutes must be positive");
    auto cutoff = nowStdTime() - timeoutMinutes.minutes.total!"hnsecs";
    size_t expired;
    foreach (s; repo.findByStatus(tenantId, SyncStatus.inProgress)) {
      if (s.startedAt == 0 || s.startedAt >= cutoff)
        continue;
      s.status = SyncStatus.failed;
      s.completedAt = nowStdTime();
      s.errorMessage = "Timed out after " ~ timeoutMinutes.to!string ~ " minutes";
      s.update();
      repo.update(s);
      expired++;
    }
    return succeeded("", "%d stale sync session(s) expired".format(expired), 200,
      Json.emptyObject.set("expired", expired));
  }

  UsecaseResult deleteSyncSession(TenantId tenantId, SyncSessionId id) {
    auto session = repo.findById(tenantId, id);
    if (session.isNull)
      return notFound("Sync session", id.value);
    if (session.status == SyncStatus.inProgress)
      return rejected("A running sync session cannot be deleted — cancel it first", id.value);
    repo.remove(session);
    return succeeded(session.id.value, "Sync session deleted");
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Apply a status change including its timestamps.
  protected void transition(ref SyncSession s, SyncStatus to) {
    if (s.status == to)
      return;
    ensureTransition("SyncSession", s.status, to);
    s.status = to;
    if (to == SyncStatus.inProgress) {
      s.startedAt = nowStdTime();
      s.completedAt = 0;
      s.errorMessage = "";
    } else if (to == SyncStatus.pending) {
      s.startedAt = 0;
      s.completedAt = 0;
    } else {
      s.completedAt = nowStdTime();
    }
  }

  protected UsecaseResult change(TenantId tenantId, SyncSessionId id,
      scope void delegate(ref SyncSession) @safe mutate, string message) {
    return guarded(() {
      auto session = repo.findById(tenantId, id);
      if (session.isNull)
        return notFound("Sync session", id.value);
      mutate(session);
      session.update();
      repo.update(session);
      return succeeded(session.id.value, message);
    });
  }

  /// A completed sync proves the device is alive and runs clientAppVersion.
  protected void markDeviceSeen(const SyncSession session) {
    if (devices is null)
      return;
    auto device = devices.findById(session.tenantId, session.deviceId);
    if (device.isNull)
      return;
    device.lastSeenAt = nowStdTime();
    if (session.clientAppVersion.length)
      device.appVersionInstalled = session.clientAppVersion;
    if (device.status == DeviceStatus.enrolled)
      device.status = DeviceStatus.active;
    device.update();
    devices.update(device);
  }
}

///
unittest {
  mixin(ShowTest!("ManageSyncSessionsUseCase"));

  auto t = TenantId("t1");
  auto devices = new DeviceRepository();
  auto device = MobileDevice(t, DeviceId("dev-1"));
  devices.save(device);

  auto uc = new ManageSyncSessionsUseCase(new SyncSessionRepository(), devices);
  SyncSessionDTO dto;
  dto.tenantId = t;
  dto.deviceId = device.id;
  dto.applicationId = MobileApplicationId("app-1");
  dto.connectionId = BackendConnectionId("con-1");
  dto.clientAppVersion = "2.0.0";
  dto.direction = "download";
  auto r = uc.createSyncSession(dto);
  assert(r.isSuccess, r.message);
  auto id = SyncSessionId(r.id);

  assert(uc.completeSyncSession(t, id, SyncMetricsDTO.init).code == 422); // not started
  assert(uc.startSyncSession(t, id).isSuccess);
  assert(uc.deleteSyncSession(t, id).code == 422);
  assert(uc.completeSyncSession(t, id, SyncMetricsDTO(10, 20, 1, 2)).isSuccess);
  auto s = uc.getSyncSession(t, id);
  assert(s.status == SyncStatus.completed && s.bytesReceived == 20 && s.completedAt >= s.startedAt);
  assert(devices.findById(t, device.id).status == DeviceStatus.active);
  assert(devices.findById(t, device.id).appVersionInstalled == "2.0.0");

  device = devices.findById(t, device.id);
  device.status = DeviceStatus.suspended;
  devices.update(device);
  assert(uc.createSyncSession(dto).code == 422);

  // stale session expiry
  auto stale = SyncSession(t, SyncSessionId("old"));
  stale.status = SyncStatus.inProgress;
  stale.startedAt = 1;
  uc.repo.save(stale);
  assert(uc.expireStaleSessions(t, 30).data["expired"].get!long == 1);
  assert(uc.getSyncSession(t, stale.id).status == SyncStatus.failed);
}
