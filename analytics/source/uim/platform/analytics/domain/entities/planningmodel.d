module uim.platform.analytics.domain.entities.planning;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.domain.values.time_granularity;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// A PlanningModel supports budget planning, forecasting, and what-if scenarios (SAC Planning).
class PlanningModel
{
  EntityId id;
  string name;
  string description;
  EntityId datasetId;
  PlanningVersion[] versions;
  TimeGranularity granularity;
  PlanningStatus planStatus;
  AuditInfo audit;

  this()
  {
  }

  static PlanningModel create(string name, string description, string datasetId,
      TimeGranularity granularity, string userId)
  {
    auto pm = new PlanningModel();
    pm.id = EntityId.generate();
    pm.name = name;
    pm.description = description;
    pm.datasetId = EntityId(datasetId);
    pm.granularity = granularity;
    pm.planStatus = PlanningStatus.Draft;
    pm.versions = [];
    pm.audit = AuditInfo.create(userId);
    // Create default "Actual" and "Plan" versions
    pm.versions ~= PlanningVersion(EntityId.generate(), "Actual", VersionType.Actual, true);
    pm.versions ~= PlanningVersion(EntityId.generate(), "Plan", VersionType.Plan, false);
    return pm;
  }

  void addForecastVersion(string name)
  {
    versions ~= PlanningVersion(EntityId.generate(), name, VersionType.Forecast, false);
  }

  void lock()
  {
    planStatus = PlanningStatus.Locked;
  }

  void unlock()
  {
    planStatus = PlanningStatus.InProgress;
  }

  void approve()
  {
    planStatus = PlanningStatus.Approved;
  }
}

enum PlanningStatus
{
  Draft,
  InProgress,
  Locked,
  Approved,
  Published,
}

enum VersionType
{
  Actual,
  Plan,
  Forecast,
  WhatIf,
}

struct PlanningVersion
{
  EntityId id;
  string name;
  VersionType versionType;
  bool isReadOnly;
}
