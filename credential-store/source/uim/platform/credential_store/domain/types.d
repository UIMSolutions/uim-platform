/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.types;

// ID aliases
alias NamespaceId = string;
alias CredentialId = string;
alias KeyringVersionId = string;
alias ServiceBindingId = string;
alias AuditLogEntryId = string;
alias TenantId = string;

// Credential types: password (text), key (binary), keyring (KEK for DEK encryption)
enum CredentialType {
  password,
  key,
  keyring,
}

enum CredentialStatus {
  active,
  disabled,
  deleted_,
}

enum OperationType {
  create,
  read,
  update,
  delete_,
  list,
  encrypt,
  decrypt,
  generate,
  rotate,
}

enum ResourceType {
  namespace,
  password,
  key,
  keyring,
  keyringVersion,
  serviceBinding,
  dek,
}

enum PermissionLevel {
  readOnly,
  readWrite,
  admin,
}

enum BindingStatus {
  active,
  revoked,
}

enum KeyringRotationPeriod {
  days30 = 30,
  days60 = 60,
  days90 = 90,
  days180 = 180,
  days365 = 365,
}
