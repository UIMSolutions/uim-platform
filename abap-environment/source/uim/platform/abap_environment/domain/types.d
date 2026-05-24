/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SystemInstanceId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct SoftwareComponentId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CatalogAssignmentId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct CommunicationArrangementId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ServiceBindingId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct BusinessUserId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct BusinessRoleId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct TransportRequestId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct TransportTaskId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ApplicationJobId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceDefinitionId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct CommunicationScenarioId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
