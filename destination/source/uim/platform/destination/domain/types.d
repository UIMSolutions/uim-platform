/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.types;
import uim.platform.destination;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct AuthTokenId {
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
struct CertificateId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct DestinationFragmentId {
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
struct DestinationLookupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
