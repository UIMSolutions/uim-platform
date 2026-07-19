/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.types;

import uim.platform.service.mixins.domain;
import uim.platform.credential_store;
mixin(ShowModule!());

@safe:

/// Strongly-typed identifier for a Namespace aggregate root.
struct NamespaceId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Credential aggregate root.
struct CredentialId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Keyring aggregate root.
struct KeyringId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Keyring Version aggregate root.
struct KeyringVersionId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for an AuditLogEntry aggregate root.
struct AuditLogEntryId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Resource Group (SAP BTP resource group concept).
struct ResourceGroupId {
  mixin(IdTemplate);
}
