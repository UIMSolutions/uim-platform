/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.manage.credentials;

// import uim.platform.credential_store.domain.ports.repositories.credentials;
// import uim.platform.credential_store.domain.entities.credential;
// import uim.platform.credential_store.domain.services.credential_validator;
// import uim.platform.credential_store.domain.types;
// import uim.platform.credential_store.application.dto;

// import std.uuid : randomUUID;
// import std.conv : to;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class ManageCredentialsUseCase { // TODO: UIMUseCase {
  private CredentialRepository credentials;

  this(CredentialRepository credentials) {
    this.credentials = credentials;
  }

  // Create or create-or-update based on ifNoneMatch header
  CommandResult create(CreateCredentialRequest r) {
    auto credType = parseCredentialType(r.type);

    auto validationError = CredentialValidator.validate(r.name, r.value, credType, r.metadata, r.format, r.username);
    if (validationError.length > 0)
      return CommandResult(false, "", validationError);

    auto existing = credentials.findByName(r.namespaceId, r.name, credType);

    // If-None-Match: * means create only (fail if exists)
    if (r.ifNoneMatch == "*" && !existing.isNull)
      return CommandResult(false, "", "Credential already exists");

    // Create or update
    if (!existing.isNull) {
      existing.value = r.value;
      existing.metadata = r.metadata;
      existing.format = r.format;
      existing.username = r.username;
      existing.version_ = existing.version_ + 1;
      existing.updatedAt = currentTimestamp();
      existing.modifiedBy = r.createdBy;
      credentials.update(existing);
      return CommandResult(true, existing.id.value, "");
    }

    Credential cred;
    cred.id = randomUUID();
    cred.namespaceId = r.namespaceId;
    cred.tenantId = r.tenantId;
    cred.name = r.name;
    cred.type = credType;
    cred.value = r.value;
    cred.metadata = r.metadata;
    cred.format = r.format;
    cred.username = r.username;
    cred.status = CredentialStatus.active;
    cred.version_ = 1;
    cred.createdAt = currentTimestamp();
    cred.updatedAt = cred.createdAt;
    cred.createdBy = r.createdBy;
    cred.modifiedBy = r.createdBy;

    credentials.save(cred);
    return CommandResult(true, cred.id.value, "");
  }

  // Update with conditional support via ifMatch header
  CommandResult update(CredentialId id, UpdateCredentialRequest r) {
    auto cred = credentials.findById(id);
    if (cred.isNull)
      return CommandResult(false, "", "Credential not found");

    // If-Match: <id> means conditional update (only if version matches)
    if (r.ifMatch.length > 0 && r.ifMatch != "*") {
      auto matchVersion = tryParseLong(r.ifMatch);
      if (matchVersion != cred.version_)
        return CommandResult(false, "", "Credential has been modified (version mismatch)");
    }

    if (r.value.length > 0)
      cred.value = r.value;
    if (r.metadata.length > 0)
      cred.metadata = r.metadata;
    if (r.format.length > 0)
      cred.format = r.format;
    if (r.username.length > 0)
      cred.username = r.username;
    cred.version_ = cred.version_ + 1;
    cred.updatedAt = currentTimestamp();
    cred.modifiedBy = r.modifiedBy;

    credentials.update(cred);
    return CommandResult(true, cred.id, "");
  }

  Credential getById(CredentialId id) {
    return credentials.findById(id);
  }

  Credential getByName(NamespaceId namespaceId, string name, string type) {
    return credentials.findByName(namespaceId, name, parseCredentialType(type));
  }

  Credential[] listByNamespace(NamespaceId namespaceId) {
    return credentials.findByNamespace(namespaceId);
  }

  Credential[] listByType(NamespaceId namespaceId, string type) {
    return credentials.findByNamespaceAndType(namespaceId, parseCredentialType(type));
  }

  void remove(CredentialId id) {
    credentials.remove(id);
  }

  size_t countByNamespace(NamespaceId namespaceId) {
    return credentials.countByNamespace(namespaceId);
  }

  size_t countByTenant(TenantId tenantId) {
    return credentials.countByTenant(tenantId);
  }

  private static CredentialType parseCredentialType(string t) {
    switch (t) {
    case "password":
      return CredentialType.password;
    case "key":
      return CredentialType.key;
    case "keyring":
      return CredentialType.keyring;
    default:
      return CredentialType.password;
    }
  }

  private static long tryParseLong(string s) {
    try
      return s.to!long;
    catch (Exception)
      return -1;
  }

  private static long currentTimestamp() {
    import std.datetime.systime : Clock;

    return Clock.currStdTime();
  }
}
