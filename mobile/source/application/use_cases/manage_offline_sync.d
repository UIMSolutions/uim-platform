/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage_offline_sync;

import uim.platform.mobile.application.dto;
import uim.platform.mobile.domain.entities.offline_config;
import uim.platform.mobile.domain.entities.sync_session;
import uim.platform.mobile.domain.ports.offline_config_repository;
import uim.platform.mobile.domain.ports.sync_session_repository;
import uim.platform.mobile.domain.types;

/// Use case: manage offline store configurations and sync sessions.
class ManageOfflineSyncUseCase
{
  private OfflineConfigRepository configRepo;
  private SyncSessionRepository sessionRepo;

  this(OfflineConfigRepository configRepo, SyncSessionRepository sessionRepo)
  {
    this.configRepo = configRepo;
    this.sessionRepo = sessionRepo;
  }

  // --- Offline Configs ---

  CommandResult createConfig(CreateOfflineConfigRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Config name is required");

    if (req.serviceUrl.length == 0)
      return CommandResult(false, "", "Service URL is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    OfflineConfig cfg;
    cfg.id = id;
    cfg.appId = req.appId;
    cfg.tenantId = req.tenantId;
    cfg.name = req.name;
    cfg.description = req.description;
    cfg.serviceUrl = req.serviceUrl;
    cfg.definingRequests = req.definingRequests;
    cfg.syncStrategy = parseSyncStrategy(req.syncStrategy);
    cfg.conflictResolution = parseConflictResolution(req.conflictResolution);
    cfg.maxStoreSize = req.maxStoreSize;
    cfg.syncIntervalSeconds = req.syncIntervalSeconds > 0 ? req.syncIntervalSeconds : 300;
    cfg.encryptStore = req.encryptStore;
    cfg.compressData = req.compressData;
    cfg.enableDeltaTracking = req.enableDeltaTracking;
    cfg.excludedEntities = req.excludedEntities;
    cfg.maxRetries = req.maxRetries > 0 ? req.maxRetries : 3;
    cfg.retryDelaySeconds = req.retryDelaySeconds > 0 ? req.retryDelaySeconds : 30;
    cfg.createdBy = req.createdBy;
    cfg.createdAt = clockSeconds();
    cfg.updatedAt = cfg.createdAt;

    configRepo.save(cfg);
    return CommandResult(true, id, "");
  }

  OfflineConfig getConfig(OfflineConfigId id)
  {
    return configRepo.findById(id);
  }

  OfflineConfig[] listConfigs(MobileAppId appId)
  {
    return configRepo.findByApp(appId);
  }

  CommandResult removeConfig(OfflineConfigId id)
  {
    auto cfg = configRepo.findById(id);
    if (cfg.id.length == 0)
      return CommandResult(false, "", "Offline config not found");
    configRepo.remove(id);
    return CommandResult(true, id, "");
  }

  // --- Sync Sessions ---

  CommandResult startSync(StartSyncSessionRequest req)
  {
    if (req.offlineConfigId.length == 0)
      return CommandResult(false, "", "Offline config ID is required");

    if (req.deviceId.length == 0)
      return CommandResult(false, "", "Device ID is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    SyncSession s;
    s.id = id;
    s.offlineConfigId = req.offlineConfigId;
    s.appId = req.appId;
    s.tenantId = req.tenantId;
    s.userId = req.userId;
    s.deviceId = req.deviceId;
    s.strategy = parseSyncStrategy(req.strategy);
    s.status = SyncSessionStatus.started;
    s.deltaToken = req.deltaToken;
    s.startedAt = clockSeconds();

    sessionRepo.save(s);
    return CommandResult(true, id, "");
  }

  CommandResult completeSync(SyncSessionId id, CompleteSyncSessionRequest req)
  {
    auto s = sessionRepo.findById(id);
    if (s.id.length == 0)
      return CommandResult(false, "", "Sync session not found");

    s.uploadedRecords = req.uploadedRecords;
    s.downloadedRecords = req.downloadedRecords;
    s.conflictCount = req.conflictCount;
    s.resolvedConflicts = req.resolvedConflicts;
    s.uploadBytes = req.uploadBytes;
    s.downloadBytes = req.downloadBytes;
    if (req.deltaToken.length > 0)
      s.deltaToken = req.deltaToken;
    s.errorMessage = req.errorMessage;
    s.status = parseSyncStatus(req.status);
    s.completedAt = clockSeconds();

    sessionRepo.update(s);
    return CommandResult(true, id, "");
  }

  SyncSession getSession(SyncSessionId id)
  {
    return sessionRepo.findById(id);
  }

  SyncSession[] listSessions(OfflineConfigId configId)
  {
    return sessionRepo.findByConfig(configId);
  }

  SyncSession[] listByDevice(string deviceId)
  {
    return sessionRepo.findByDevice(deviceId);
  }
}

private SyncStrategy parseSyncStrategy(string s)
{
  switch (s)
  {
  case "fullSync":
    return SyncStrategy.fullSync;
  case "onDemand":
    return SyncStrategy.onDemand;
  case "backgroundSync":
    return SyncStrategy.backgroundSync;
  default:
    return SyncStrategy.deltaSync;
  }
}

private ConflictResolution parseConflictResolution(string s)
{
  switch (s)
  {
  case "clientWins":
    return ConflictResolution.clientWins;
  case "serverWins":
    return ConflictResolution.serverWins;
  case "manual":
    return ConflictResolution.manual;
  case "merge":
    return ConflictResolution.merge;
  default:
    return ConflictResolution.lastWriteWins;
  }
}

private SyncSessionStatus parseSyncStatus(string s)
{
  switch (s)
  {
  case "failed":
    return SyncSessionStatus.failed;
  case "conflicted":
    return SyncSessionStatus.conflicted;
  case "cancelled":
    return SyncSessionStatus.cancelled;
  default:
    return SyncSessionStatus.completed;
  }
}

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 1_000_000_000;
}
