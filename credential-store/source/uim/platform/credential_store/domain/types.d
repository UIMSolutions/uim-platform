/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.types;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
// ID aliases
struct NamespaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CredentialId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CredentialId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct KeyringVersionId {
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

struct AuditLogEntryId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
