module uim.platform.content_agent.application.usecases.monitor_activities;

import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.ports.content_activity_repository;
import uim.platform.content_agent.domain.types;

// import std.conv : to;

/// Application service for viewing content operation activities.
class MonitorActivitiesUseCase
{
  private ContentActivityRepository activityRepo;

  this(ContentActivityRepository activityRepo)
  {
    this.activityRepo = activityRepo;
  }

  ContentActivity[] listActivities(TenantId tenantId, int limit = 50)
  {
    return activityRepo.findRecent(tenantId, limit);
  }

  ContentActivity[] listByEntity(string entityId)
  {
    return activityRepo.findByEntity(entityId);
  }

  ContentActivity[] listByType(TenantId tenantId, string activityTypeStr)
  {
    auto actType = parseActivityType(activityTypeStr);
    return activityRepo.findByType(tenantId, actType);
  }

  /// Produce a summary of recent activities by type.
  ActivitySummary getSummary(TenantId tenantId)
  {
    auto all = activityRepo.findRecent(tenantId, 1000);

    ActivitySummary summary;
    summary.totalCount = cast(long) all.length;

    foreach (ref a; all)
    {
      final switch (a.severity)
      {
      case ActivitySeverity.info:
        summary.infoCount++;
        break;
      case ActivitySeverity.warning:
        summary.warningCount++;
        break;
      case ActivitySeverity.error:
        summary.errorCount++;
        break;
      }
    }

    return summary;
  }

  private static ActivityType parseActivityType(string s)
  {
    switch (s)
    {
    case "packageCreated":
      return ActivityType.packageCreated;
    case "packageAssembled":
      return ActivityType.packageAssembled;
    case "packageExported":
      return ActivityType.packageExported;
    case "packageImported":
      return ActivityType.packageImported;
    case "packageDeleted":
      return ActivityType.packageDeleted;
    case "providerRegistered":
      return ActivityType.providerRegistered;
    case "providerDeregistered":
      return ActivityType.providerDeregistered;
    case "transportCreated":
      return ActivityType.transportCreated;
    case "transportReleased":
      return ActivityType.transportReleased;
    case "transportFailed":
      return ActivityType.transportFailed;
    case "exportStarted":
      return ActivityType.exportStarted;
    case "exportCompleted":
      return ActivityType.exportCompleted;
    case "exportFailed":
      return ActivityType.exportFailed;
    case "importStarted":
      return ActivityType.importStarted;
    case "importCompleted":
      return ActivityType.importCompleted;
    case "importFailed":
      return ActivityType.importFailed;
    case "queueConfigured":
      return ActivityType.queueConfigured;
    default:
      return ActivityType.packageCreated;
    }
  }
}

struct ActivitySummary
{
  long totalCount;
  long infoCount;
  long warningCount;
  long errorCount;
}
