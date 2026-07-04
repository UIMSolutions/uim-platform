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


struct DirectoryId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}


struct EntitlementId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct EnvironmentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct SubscriptionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ServicePlanId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct EnvironmentEventId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct LabelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

