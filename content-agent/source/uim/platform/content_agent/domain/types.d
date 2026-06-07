/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.types;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct ContentPackageId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentTypeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentProviderId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TransportRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ExportJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ImportJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TransportQueueId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentActivityId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}