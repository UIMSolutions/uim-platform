/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct KymaEnvironmentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct NamespaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServerlessFunctionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ApiRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceBindingId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct EventSubscriptionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct KymaModuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ApplicationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ClusterId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

