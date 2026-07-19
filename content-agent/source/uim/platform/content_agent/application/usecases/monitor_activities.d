/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.monitor_activities;

// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;


import uim.platform.content_agent;
mixin(ShowModule!());

@safe:
/// Application service for viewing content operation activities.
class MonitorActivitiesUseCase { // TODO: UIMUseCase {
  private ContentActivityRepository activityRepo;

  this(ContentActivityRepository activityRepo) {
    this.activityRepo = activityRepo;
  }

  ContentActivity[] listActivities(TenantId tenantId, int limit = 50) {
    return activityRepo.findRecent(tenantId, limit);
  }

  ContentActivity[] listByEntity(TenantId tenantId, string entityId) {
    return activityRepo.findByEntity(tenantId, entityId);
  }

  ContentActivity[] listByType(TenantId tenantId, string activityTypeStr) {
    return activityRepo.findByType(tenantId, activityTypeStr.toActivityType);
  }

  /// Produce a summary of recent activities by type.
  ActivitySummary getSummary(TenantId tenantId) {
    auto all = activityRepo.findRecent(tenantId, 1000);

    ActivitySummary summary;
    summary.totalCount = all.length;

    foreach (a; all) {
      final switch (a.severity) {
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
}

struct ActivitySummary {
  long totalCount;
  long infoCount;
  long warningCount;
  long errorCount;
}
