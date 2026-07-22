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

CredentialType toCredentialType(string value) {
  mixin(EnumSwitch("CredentialType", "password"));
}

CredentialType[] toCredentialTypes(string[] values)
  => values.map!toCredentialType.array;

string toString(CredentialType value)
  => value.to!string;

string[] toStrings(CredentialType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("CredentialType"));

  assert("password".toCredentialType == CredentialType.password);
  assert("key".toCredentialType == CredentialType.key);
  assert("keyring".toCredentialType == CredentialType.keyring);

  assert("".toCredentialType == CredentialType.password);
  assert("unknown".toCredentialType == CredentialType.password);

  assert(CredentialType.password.toString == "password");
  assert(CredentialType.key.toString == "key");
  assert(CredentialType.keyring.toString == "keyring");

  assert(["password", "key"].toCredentialTypes == [
      CredentialType.password, CredentialType.key
    ]);
  assert([CredentialType.password, CredentialType.key].toStrings == ["password", "key"]);
}

enum CredentialStatus {
  active,
  disabled,
  deleted_,
}

CredentialStatus toCredentialStatus(string value) {
  switch (value.toLower()) {
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

CredentialStatus[] toCredentialStatuses(string[] values)
  => values.map!toCredentialStatus.array;

string toString(CredentialStatus value)
  => value.to!string;

string[] toStrings(CredentialStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("CredentialStatus"));

  assert("active".toCredentialStatus == CredentialStatus.active);
  assert("disabled".toCredentialStatus == CredentialStatus.disabled);
  assert("deleted".toCredentialStatus == CredentialStatus.deleted_);

  assert("".toCredentialStatus == CredentialStatus.active);
  assert("unknown".toCredentialStatus == CredentialStatus.active);

  assert(CredentialStatus.active.toString == "active");
  assert(CredentialStatus.disabled.toString == "disabled");
  assert(CredentialStatus.deleted_.toString == "deleted");

  assert(["active", "disabled"].toCredentialStatuses == [
      CredentialStatus.active, CredentialStatus.disabled
    ]);
  assert([CredentialStatus.active, CredentialStatus.disabled].toStrings == [
      "active", "disabled"
    ]);

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

OperationType toOperationType(string value) {
  switch (value.toLower()) {
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

OperationType[] toOperationTypes(string[] values)
  => values.map!toOperationType.array;

string toString(OperationType value)
  => value.to!string;

string[] toStrings(OperationType[] values)  
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("OperationType"));

  assert("create".toOperationType == OperationType.create);
  assert("read".toOperationType == OperationType.read);
  assert("update".toOperationType == OperationType.update);
  assert("delete".toOperationType == OperationType.delete_);
  assert("list".toOperationType == OperationType.list);
  assert("encrypt".toOperationType == OperationType.encrypt);
  assert("decrypt".toOperationType == OperationType.decrypt);
  assert("generate".toOperationType == OperationType.generate);
  assert("rotate".toOperationType == OperationType.rotate);

  assert("".toOperationType == OperationType.read);
  assert("unknown".toOperationType == OperationType.read);

  assert(OperationType.create.toString == "create");
  assert(OperationType.read.toString == "read");
  assert(OperationType.update.toString == "update");
  assert(OperationType.delete_.toString == "delete_");
  assert(OperationType.list.toString == "list");
  assert(OperationType.encrypt.toString == "encrypt");
  assert(OperationType.decrypt.toString == "decrypt");
  assert(OperationType.generate.toString == "generate");
  assert(OperationType.rotate.toString == "rotate");

  assert(["create", "read"].toOperationTypes == [
      OperationType.create, OperationType.read
    ]);
  assert([OperationType.create, OperationType.read].toStrings == [
      "create", "read"
    ]);
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

ResourceType toResourceType(string value) {
  mixin(EnumSwitch("ResourceType", "namespace"));
}

ResourceType[] toResourceTypes(string[] values)
  => values.map!toResourceType.array;

string toString(ResourceType type)
  => type.to!string;

string[] toStrings(ResourceType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ResourceType"));

  assert("namespace".toResourceType == ResourceType.namespace);
  assert("password".toResourceType == ResourceType.password);
  assert("key".toResourceType == ResourceType.key);
  assert("keyring".toResourceType == ResourceType.keyring); 
  assert("keyringVersion".toResourceType == ResourceType.keyringVersion);
  assert("serviceBinding".toResourceType == ResourceType.serviceBinding);
  assert("dek".toResourceType == ResourceType.dek);

  assert("".toResourceType == ResourceType.namespace);
  assert("unknown".toResourceType == ResourceType.namespace);

  assert(ResourceType.namespace.toString == "namespace");
  assert(ResourceType.password.toString == "password");
  assert(ResourceType.key.toString == "key");
  assert(ResourceType.keyring.toString == "keyring");
  assert(ResourceType.keyringVersion.toString == "keyringVersion");
  assert(ResourceType.serviceBinding.toString == "serviceBinding");
  assert(ResourceType.dek.toString == "dek");

  assert(["namespace", "key"].toResourceTypes == [
      ResourceType.namespace, ResourceType.key
    ]);
  assert([ResourceType.namespace, ResourceType.key].toStrings == [
      "namespace", "key"
    ]);
}

enum PermissionLevel {
  readWrite,
  readOnly,
  admin,
}

PermissionLevel toPermissionLevel(string value) {
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

BindingStatus toBindingStatus(string value) {
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

KeyringRotationPeriod toKeyringRotationPeriod(string value) {
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
