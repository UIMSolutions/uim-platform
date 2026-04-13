/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct DestinationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ConnectorId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ChannelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RuleId {
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

struct ConnectivityLogId {
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
