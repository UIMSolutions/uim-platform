module uim.platform.credential_store.domain.enumerations;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
// Credential types: password (text), key (binary), keyring (KEK for DEK encryption)
enum CredentialType {
  password,
  key,
  keyring,
}

CredentialType toCredentialType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "password":
    return CredentialType.password;
  case "key":
    return CredentialType.key;
  case "keyring":
    return CredentialType.keyring;
  default:
    return CredentialType.password; // Default case
  }
}

enum CredentialStatus {
  active,
  disabled,
  deleted_,
}

CredentialStatus toCredentialStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "active":
    return CredentialStatus.active;
  case "disabled":
    return CredentialStatus.disabled;
  case "deleted":
    return CredentialStatus.deleted_;
  default:
    return CredentialStatus.active; // Default case
  }
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

OperationType toOperationType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "create":
    return OperationType.create;
  case "read":
    return OperationType.read;
  case "update":
    return OperationType.update;
  case "delete":
    return OperationType.delete_;
  case "list":
    return OperationType.list;
  case "encrypt":
    return OperationType.encrypt;
  case "decrypt":
    return OperationType.decrypt;
  case "generate":
    return OperationType.generate;
  case "rotate":
    return OperationType.rotate;
  default:
    return OperationType.read; // Default case
  }
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

ResourceType toResourceType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "namespace":
    return ResourceType.namespace;
  case "password":
    return ResourceType.password;
  case "key":
    return ResourceType.key;
  case "keyring":
    return ResourceType.keyring;
  case "keyringversion":
    return ResourceType.keyringVersion;
  case "servicebinding":
    return ResourceType.serviceBinding;
  case "dek":
    return ResourceType.dek;
  default:
    return ResourceType.namespace; // Default case
  }
}

enum PermissionLevel {
  readWrite,
  readOnly,
  admin,
}

PermissionLevel toPermissionLevel(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "readwrite":
    return PermissionLevel.readWrite;
  case "readonly":
    return PermissionLevel.readOnly;
  case "admin":
    return PermissionLevel.admin;
  default:
    return PermissionLevel.readOnly; // Default case
  }
}

enum BindingStatus {
  active,
  revoked,
}

BindingStatus toBindingStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "active":
    return BindingStatus.active;
  case "revoked":
    return BindingStatus.revoked;
  default:
    return BindingStatus.active; // Default case
  }
}

enum KeyringRotationPeriod {
  days30 = 30,
  days60 = 60,
  days90 = 90,
  days180 = 180,
  days365 = 365,
}

KeyringRotationPeriod toKeyringRotationPeriod(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
  case "30":
    return KeyringRotationPeriod.days30;
  case "60":
    return KeyringRotationPeriod.days60;
  case "90":
    return KeyringRotationPeriod.days90;
  case "180":
    return KeyringRotationPeriod.days180;
  case "365":
    return KeyringRotationPeriod.days365;
  default:
    return KeyringRotationPeriod.days90; // Default case
  }
}
