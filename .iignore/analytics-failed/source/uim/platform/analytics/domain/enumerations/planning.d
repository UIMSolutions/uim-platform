module uim.platform.analytics.domain.enumerations.planning;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
enum PlanningStatus {
  // Used for plans that are still being developed and have not yet been finalized or approved
  Draft, 
  // Used for plans that are currently being executed or implemented, but may still be subject to change
  InProgress, 
  // Used for plans that have been finalized and approved, and are now locked from further editing or changes
  Locked, 
  // Used for plans that have been reviewed and approved by the necessary stakeholders, but may not yet be published or implemented
  Approved, 
  // Used for plans that have been finalized, approved, and published for use by the organization or external stakeholders
  Published, 
}
PlanningStatus toPlanningStatus(string status) {
  const map = [
    "draft": PlanningStatus.Draft,
    "inprogress": PlanningStatus.InProgress,
    "locked": PlanningStatus.Locked,
    "approved": PlanningStatus.Approved,
    "published": PlanningStatus.Published,
  ];
  return map.get(status.toLower, PlanningStatus.Draft);
}

enum PlanningVersionType {
  // Used for versions that represent actual historical data or results, which can be used for analysis and comparison against plans and forecasts
  Actual, 
  // Plan, Used for versions that represent planned or target values, which can be used for setting goals and measuring performance against those goals
  Plan,
  // Used for versions that represent planned or target values, which can be used for setting goals and measuring performance against those goals
  Forecast,
  // Used for versions that represent hypothetical scenarios or what-if analyses, which can be used for exploring potential outcomes and making informed decisions
  WhatIf
}
PlanningVersionType toPlanningVersionType(string type) {
  const map = [
    "actual": PlanningVersionType.Actual,
    "plan": PlanningVersionType.Plan,
    "forecast": PlanningVersionType.Forecast,
    "whatif": PlanningVersionType.WhatIf
  ];
  return map.get(type.toLower, PlanningVersionType.Plan);
}