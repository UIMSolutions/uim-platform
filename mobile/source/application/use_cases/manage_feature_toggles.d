/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage_feature_toggles;

import uim.platform.mobile.application.dto;
import uim.platform.mobile.domain.entities.feature_toggle;
import uim.platform.mobile.domain.ports.feature_toggle_repository;
import uim.platform.mobile.domain.types;

/// Use case: manage feature toggles / feature flags for mobile apps.
class ManageFeatureTogglesUseCase
{
  private FeatureToggleRepository repo;

  this(FeatureToggleRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateFeatureToggleRequest req)
  {
    if (req.key.length == 0)
      return CommandResult(false, "", "Feature key is required");

    if (req.appId.length == 0)
      return CommandResult(false, "", "App ID is required");

    // Check key uniqueness within app
    auto existing = repo.findByKey(req.appId, req.key);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Feature key already exists for this app");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    FeatureToggle t;
    t.id = id;
    t.appId = req.appId;
    t.tenantId = req.tenantId;
    t.key = req.key;
    t.name = req.name.length > 0 ? req.name : req.key;
    t.description = req.description;
    t.status = parseToggleStatus(req.status);
    t.rolloutPercentage = req.rolloutPercentage;
    t.enabledUserIds = req.enabledUserIds;
    t.enabledSegments = req.enabledSegments;
    t.platforms = parsePlatforms(req.platforms);
    t.minimumAppVersion = req.minimumAppVersion;
    t.defaultValue = req.defaultValue;
    t.enabledValue = req.enabledValue;
    t.variantJson = req.variantJson;
    t.scheduledEnableAt = req.scheduledEnableAt;
    t.scheduledDisableAt = req.scheduledDisableAt;
    t.createdBy = req.createdBy;
    t.createdAt = clockSeconds();
    t.updatedAt = t.createdAt;

    repo.save(t);
    return CommandResult(true, id, "");
  }

  CommandResult enable(FeatureToggleId id)
  {
    auto t = repo.findById(id);
    if (t.id.length == 0)
      return CommandResult(false, "", "Feature toggle not found");
    t.status = ToggleStatus.enabled;
    t.updatedAt = clockSeconds();
    repo.update(t);
    return CommandResult(true, id, "");
  }

  CommandResult disable(FeatureToggleId id)
  {
    auto t = repo.findById(id);
    if (t.id.length == 0)
      return CommandResult(false, "", "Feature toggle not found");
    t.status = ToggleStatus.disabled;
    t.updatedAt = clockSeconds();
    repo.update(t);
    return CommandResult(true, id, "");
  }

  /// Evaluate all toggles for a given client context.
  string[string] evaluate(EvaluateToggleRequest req)
  {
    string[string] result;
    auto toggles = repo.findByApp(req.appId);

    foreach (ref t; toggles)
    {
      result[t.key] = evaluateToggle(t, req);
    }
    return result;
  }

  FeatureToggle getById(FeatureToggleId id)
  {
    return repo.findById(id);
  }

  FeatureToggle[] listByApp(MobileAppId appId)
  {
    return repo.findByApp(appId);
  }

  CommandResult remove(FeatureToggleId id)
  {
    auto t = repo.findById(id);
    if (t.id.length == 0)
      return CommandResult(false, "", "Feature toggle not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private string evaluateToggle(ref FeatureToggle t, EvaluateToggleRequest req)
  {
    // Disabled = default value
    if (t.status == ToggleStatus.disabled)
      return t.defaultValue;

    // Check platform gate
    if (t.platforms.length > 0)
    {
      auto clientPlatform = parsePlatform(req.platform);
      // import std.algorithm : canFind;
      if (!t.platforms.canFind(clientPlatform))
        return t.defaultValue;
    }

    // Check explicit user override
    if (t.enabledUserIds.length > 0)
    {
      // import std.algorithm : canFind;
      if (t.enabledUserIds.canFind(req.userId))
        return t.enabledValue;
    }

    // Percentage rollout
    if (t.status == ToggleStatus.percentage)
    {
      auto hash = simpleHash(req.userId ~ t.key);
      if ((hash % 100) < t.rolloutPercentage)
        return t.enabledValue;
      return t.defaultValue;
    }

    // Fully enabled
    if (t.status == ToggleStatus.enabled)
      return t.enabledValue;

    return t.defaultValue;
  }

  private uint simpleHash(string s)
  {
    uint h = 0;
    foreach (c; s)
      h = h * 31 + c;
    return h;
  }
}

private ToggleStatus parseToggleStatus(string s)
{
  switch (s)
  {
  case "enabled":
    return ToggleStatus.enabled;
  case "percentage":
    return ToggleStatus.percentage;
  case "userSegment":
    return ToggleStatus.userSegment;
  case "scheduled":
    return ToggleStatus.scheduled;
  default:
    return ToggleStatus.disabled;
  }
}

private MobilePlatform[] parsePlatforms(string[] platforms)
{
  MobilePlatform[] result;
  foreach (p; platforms)
  {
    switch (p)
    {
    case "ios":
      result ~= MobilePlatform.ios;
      break;
    case "android":
      result ~= MobilePlatform.android;
      break;
    case "windows":
      result ~= MobilePlatform.windows;
      break;
    case "webApp":
      result ~= MobilePlatform.webApp;
      break;
    default:
      break;
    }
  }
  return result;
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

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 1_000_000_000;
}
