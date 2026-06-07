/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct ScenarioId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct WorkflowId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct StepId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SystemConnectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DestinationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TaskAssignmentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ExecutionLogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}