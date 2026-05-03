/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.entities.key_password;

// import uim.platform.keystore.domain.types;

import uim.platform.keystore.application.dto;

mixin(ShowModule!());

@safe:

/// A stored password or key phrase that protects a keystore or key entry.
/// Passwords are encrypted at rest and scoped per application/subscription.
struct KeyPassword {
  KeyPasswordId id;
  string alias_; // user-defined alias for this password
  string passwordValue; // stored opaque/encrypted value
  string accountId;
  string applicationId;
  TenantId tenantId;
  long createdAt;
  long updatedAt;
}
