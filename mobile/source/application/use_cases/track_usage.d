/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.track_usage;

import uim.platform.mobile.application.dto;
import uim.platform.mobile.domain.entities.usage_event;
import uim.platform.mobile.domain.entities.client_log;
import uim.platform.mobile.domain.ports.usage_event_repository;
import uim.platform.mobile.domain.ports.client_log_repository;
import uim.platform.mobile.domain.ports.device_registration_repository;
import uim.platform.mobile.domain.types;

/// Use case: track mobile usage events, analytics, and client logs.
class TrackUsageUseCase
{
  private UsageEventRepository eventRepo;
  private ClientLogRepository logRepo;
  private DeviceRegistrationRepository deviceRepo;

  this(UsageEventRepository eventRepo, ClientLogRepository logRepo,
      DeviceRegistrationRepository deviceRepo)
  {
    this.eventRepo = eventRepo;
    this.logRepo = logRepo;
    this.deviceRepo = deviceRepo;
  }

  // --- Usage Events ---

  CommandResult recordEvent(RecordUsageEventRequest req)
  {
    if (req.appId.length == 0)
      return CommandResult(false, "", "App ID is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    UsageEvent e;
    e.id = id;
    e.appId = req.appId;
    e.tenantId = req.tenantId;
    e.userId = req.userId;
    e.deviceId = req.deviceId;
    e.eventType = parseEventType(req.eventType);
    e.eventName = req.eventName;
    e.screenName = req.screenName;
    e.appVersion = req.appVersion;
    e.platform = parsePlatform(req.platform);
    e.durationMs = req.durationMs;
    e.properties = req.properties;
    e.responseTimeMs = req.responseTimeMs;
    e.memoryUsageBytes = req.memoryUsageBytes;
    e.cpuUsagePercent = req.cpuUsagePercent;
    e.batteryLevel = req.batteryLevel;
    e.networkType = req.networkType;
    e.timestamp = clockSeconds();

    eventRepo.save(e);
    return CommandResult(true, id, "");
  }

  UsageEvent[] listByApp(MobileAppId appId)
  {
    return eventRepo.findByApp(appId);
  }

  UsageEvent[] listByUser(MobileAppId appId, string userId)
  {
    return eventRepo.findByUser(appId, userId);
  }

  UsageEvent[] listByType(MobileAppId appId, string eventType)
  {
    return eventRepo.findByType(appId, parseEventType(eventType));
  }

  // --- Client Logs ---

  CommandResult uploadLog(UploadClientLogRequest req)
  {
    if (req.appId.length == 0)
      return CommandResult(false, "", "App ID is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    ClientLog l;
    l.id = id;
    l.appId = req.appId;
    l.tenantId = req.tenantId;
    l.userId = req.userId;
    l.deviceId = req.deviceId;
    l.severity = parseSeverity(req.severity);
    l.message = req.message;
    l.source = req.source;
    l.stackTrace = req.stackTrace;
    l.appVersion = req.appVersion;
    l.platform = parsePlatform(req.platform);
    l.osVersion = req.osVersion;
    l.context = req.context;
    l.timestamp = clockSeconds();
    l.uploadedAt = l.timestamp;

    logRepo.save(l);
    return CommandResult(true, id, "");
  }

  ClientLog[] listLogs(MobileAppId appId)
  {
    return logRepo.findByApp(appId);
  }

  ClientLog[] listLogsBySeverity(MobileAppId appId, string severity)
  {
    return logRepo.findBySeverity(appId, parseSeverity(severity));
  }

  // --- Analytics Summary ---

  AppAnalyticsSummary getSummary(MobileAppId appId)
  {
    AppAnalyticsSummary s;
    auto devices = deviceRepo.findByApp(appId);
    s.totalDevices = cast(long) devices.length;

    // import std.algorithm : filter, count;
    s.activeDevices = cast(long) devices.filter!(d => d.status == DeviceStatus.active).count;

    auto events = eventRepo.findByApp(appId);
    s.totalEvents = cast(long) events.length;
    s.crashCount = cast(long) events.filter!(e => e.eventType == UsageEventType.crash).count;

    return s;
  }
}

private UsageEventType parseEventType(string s)
{
  switch (s)
  {
  case "appLaunch":
    return UsageEventType.appLaunch;
  case "screenView":
    return UsageEventType.screenView;
  case "userAction":
    return UsageEventType.userAction;
  case "apiCall":
    return UsageEventType.apiCall;
  case "crash":
    return UsageEventType.crash;
  case "performanceMetric":
    return UsageEventType.performanceMetric;
  case "backgroundTask":
    return UsageEventType.backgroundTask;
  case "pushReceived":
    return UsageEventType.pushReceived;
  case "syncCompleted":
    return UsageEventType.syncCompleted;
  default:
    return UsageEventType.userAction;
  }
}

private MobilePlatform parsePlatform(string s)
{
  switch (s)
  {
  case "ios":
    return MobilePlatform.ios;
  case "android":
    return MobilePlatform.android;
  case "windows":
    return MobilePlatform.windows;
  case "webApp":
    return MobilePlatform.webApp;
  default:
    return MobilePlatform.ios;
  }
}

private LogSeverity parseSeverity(string s)
{
  switch (s)
  {
  case "debug_":
    return LogSeverity.debug_;
  case "warning":
    return LogSeverity.warning;
  case "error":
    return LogSeverity.error;
  case "fatal":
    return LogSeverity.fatal;
  default:
    return LogSeverity.info;
  }
}

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 1_000_000_000;
}
