module uim.platform.analytics.domain.enumerations.planning;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
enum PlanningStatus {
  Draft,
  InProgress,
  Locked,
  Approved,
  Published,
}
PlanningStatus toPlanningStatus(string status) {
  final map = [
    "draft": PlanningStatus.Draft,
    "inprogress": PlanningStatus.InProgress,
    "locked": PlanningStatus.Locked,
    "approved": PlanningStatus.Approved,
    "published": PlanningStatus.Published,
  ];
  return map.get(status.toLower, PlanningStatus.Draft);
}

enum PlanningVersionType {
  Actual,
  Plan,
  Forecast,
  WhatIf
}
PlanningVersionType toPlanningVersionType(string type) {
  final map = [
    "actual": PlanningVersionType.Actual,
    "plan": PlanningVersionType.Plan,
    "forecast": PlanningVersionType.Forecast,
    "whatif": PlanningVersionType.WhatIf
  ];
  return map.get(type.toLower, PlanningVersionType.Plan);
}