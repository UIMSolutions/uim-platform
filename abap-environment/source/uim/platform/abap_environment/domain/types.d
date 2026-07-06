/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SystemInstanceId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Software Component aggregate root.
struct SoftwareComponentId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Software Component Version aggregate root.
struct CatalogAssignmentId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Software Component Version aggregate root.
struct CommunicationArrangementId  {
  mixin(IdTemplate);
}


/// Strongly-typed identifier for a Business User aggregate root.
struct BusinessUserId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Business Role aggregate root.
struct BusinessRoleId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Business Role Assignment aggregate root.
struct BusinessRoleAssignmentId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Transport Request aggregate root.
struct TransportRequestId  {
  mixin(IdTemplate);
  }

/// Strongly-typed identifier for a Transport Task aggregate root.
struct TransportTaskId  {
  mixin(IdTemplate);
}

struct ApplicationJobId  {
  mixin(IdTemplate);
}
/// Strongly-typed identifier for a Application Job Log aggregate root.
struct ApplicationJobLogId  {
  mixin(IdTemplate);
}

struct ApplicationJobLogEntryId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Service Definition aggregate root.
struct ServiceDefinitionId  {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Communication Scenario aggregate root.
struct CommunicationScenarioId  {
  mixin(IdTemplate);
}




