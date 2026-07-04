/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.types;

import uim.platform.identity.provisioning;

mixin(ShowModule!());

@safe:
// --- Type Aliases ---
struct SourceSystemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TargetSystemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ProxySystemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TransformationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ProvisioningJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ProvisioningLogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ProvisionedEntityId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}