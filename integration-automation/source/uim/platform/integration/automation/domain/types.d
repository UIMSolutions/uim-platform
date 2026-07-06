/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct ScenarioId {
  mixin(IdTemplate);
}

struct WorkflowId {
  mixin(IdTemplate);
}

struct StepId {
  mixin(IdTemplate);
}

struct SystemConnectionId {
  mixin(IdTemplate);
}

struct DestinationId {
  mixin(IdTemplate);
}

struct TaskAssignmentId {
  mixin(IdTemplate);
}

struct ExecutionLogId {
  mixin(IdTemplate);
}