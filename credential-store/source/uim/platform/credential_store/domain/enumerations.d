module uim.platform.credential_store.domain.enumerations;

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
