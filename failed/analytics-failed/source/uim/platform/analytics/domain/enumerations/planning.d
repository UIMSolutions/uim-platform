/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.enumerations.planning;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
enum PlanningStatus {
  // Used for plans that are still being developed and have not yet been finalized or approved
  draft, 
  // Used for plans that are currently being executed or implemented, but may still be subject to change
  inProgress, 
  // Used for plans that have been finalized and approved, and are now locked from further editing or changes
  locked, 
  // Used for plans that have been reviewed and approved by the necessary stakeholders, but may not yet be published or implemented
  approved, 
  // Used for plans that have been finalized, approved, and published for use by the organization or external stakeholders
  published, 
}
PlanningStatus toPlanningStatus(string status) {
  mixin(EnumSwitch("PlanningStatus", "draft"));
}
PlanningStatus[] toPlanningStatuses(string[] statuses) {
  return statuses.map!(toPlanningStatus).array;
}
string toString(PlanningStatus status) {
  return status.to!string;
}
string[] toStrings(PlanningStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PlanningStatus"));

  assert(PlanningStatus.draft.toString == "draft");
  assert(PlanningStatus.inProgress.toString == "inProgress");
  assert(PlanningStatus.locked.toString == "locked");
  assert(PlanningStatus.approved.toString == "approved");
  assert(PlanningStatus.published.toString == "published"); 

  assert("".toPlanningStatus == PlanningStatus.draft); // Default case
  assert("noexists".toPlanningStatus == PlanningStatus.draft); // Default case

  assert("draft".toPlanningStatus == PlanningStatus.draft);
  assert("inProgress".toPlanningStatus == PlanningStatus.inProgress);
  assert("locked".toPlanningStatus == PlanningStatus.locked);
  assert("approved".toPlanningStatus == PlanningStatus.approved);
  assert("published".toPlanningStatus == PlanningStatus.published); 

  assert(["draft", "inProgress", "locked", "approved", "published"].toPlanningStatuses ==
         [PlanningStatus.draft, PlanningStatus.inProgress, PlanningStatus.locked, PlanningStatus.approved, PlanningStatus.published]);
  assert(toString([PlanningStatus.draft, PlanningStatus.inProgress, PlanningStatus.locked, PlanningStatus.approved, PlanningStatus.published]) ==
         ["draft", "inProgress", "locked", "approved", "published"]);
}

enum PlanningVersionType {
  // Used for versions that represent actual historical data or results, which can be used for analysis and comparison against plans and forecasts
  actual, 
  // Plan, Used for versions that represent planned or target values, which can be used for setting goals and measuring performance against those goals
  plan,
  // Used for versions that represent planned or target values, which can be used for setting goals and measuring performance against those goals
  forecast,
  // Used for versions that represent hypothetical scenarios or what-if analyses, which can be used for exploring potential outcomes and making informed decisions
  whatIf
}
PlanningVersionType toPlanningVersionType(string type) {
  mixin(EnumSwitch("PlanningVersionType", "actual"));
}
PlanningVersionType[] toPlanningVersionTypes(string[] types) {
  return types.map!(toPlanningVersionType).array;
}
string toString(PlanningVersionType type) {
  return type.to!string;
}
string[] toStrings(PlanningVersionType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PlanningVersionType"));

  assert(PlanningVersionType.actual.toString == "actual");
  assert(PlanningVersionType.plan.toString == "plan");
  assert(PlanningVersionType.forecast.toString == "forecast");
  assert(PlanningVersionType.whatIf.toString == "whatIf");

  assert("actual".toPlanningVersionType == PlanningVersionType.actual);
  assert("plan".toPlanningVersionType == PlanningVersionType.plan);
  assert("forecast".toPlanningVersionType == PlanningVersionType.forecast);
  assert("whatIf".toPlanningVersionType == PlanningVersionType.whatIf);

  assert(["actual", "plan", "forecast", "whatIf"].toPlanningVersionTypes ==
         [PlanningVersionType.actual, PlanningVersionType.plan, PlanningVersionType.forecast, PlanningVersionType.whatIf]);
  assert(toString([PlanningVersionType.actual, PlanningVersionType.plan, PlanningVersionType.forecast, PlanningVersionType.whatIf]) ==
         ["actual", "plan", "forecast", "whatIf"]);
}