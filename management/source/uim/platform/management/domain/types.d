/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Unique identifier type aliases for type safety.
struct GlobalAccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DirectoryId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct EntitlementId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct EnvironmentInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SubscriptionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServicePlanId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PlatformEventId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct LabelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

