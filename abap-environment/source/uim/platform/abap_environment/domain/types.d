/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

// // mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SystemInstanceId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct SoftwareComponentId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct CatalogAssignmentId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct CommunicationArrangementId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct ServiceBindingId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct BusinessUserId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct BusinessRoleId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct TransportRequestId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct TransportTaskId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct ApplicationJobId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ServiceDefinitionId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct CommunicationScenarioId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
