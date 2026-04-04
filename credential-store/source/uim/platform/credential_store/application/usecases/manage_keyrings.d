/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.manage_keyrings;

import uim.platform.credential_store.domain.ports.credential_repository;
import uim.platform.credential_store.domain.ports.keyring_version_repository;
import uim.platform.credential_store.domain.entities.credential;
import uim.platform.credential_store.domain.entities.keyring_version;
import uim.platform.credential_store.domain.services.keyring_manager;
import uim.platform.credential_store.domain.types;
import uim.platform.credential_store.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageKeyringsUseCase : UIMUseCase {
  private CredentialRepository credRepo;
  private KeyringVersionRepository versionRepo;

  this(CredentialRepository credRepo, KeyringVersionRepository versionRepo) {
    this.credRepo = credRepo;
    this.versionRepo = versionRepo;
  }

  CommandResult create(CreateKeyringRequest r) {
    if (r.name.length == 0 || r.name.length > 255)
      return CommandResult(false, "", "Keyring name must be 1-255 characters");

    auto existing = credRepo.findByName(r.namespaceId, r.name, CredentialType.keyring);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Keyring already exists in this namespace");

    auto now = currentTimestamp();

    // Create keyring credential entry
    Credential cred;
    cred.id = randomUUID().to!string;
    cred.namespaceId = r.namespaceId;
    cred.tenantId = r.tenantId;
    cred.name = r.name;
    cred.type = CredentialType.keyring;
    cred.metadata = r.metadata;
    cred.format = r.format;
    cred.status = CredentialStatus.active;
    cred.version_ = 1;
    cred.createdAt = now;
    cred.updatedAt = now;
    cred.createdBy = r.createdBy;
    cred.modifiedBy = r.createdBy;

    credRepo.save(cred);

    // Create initial version with generated key material
    KeyringVersion ver;
    ver.id = randomUUID().to!string;
    ver.keyringId = cred.id;
    ver.tenantId = r.tenantId;
    ver.versionNumber = 1;
    ver.keyMaterial = KeyringManager.generateKeyMaterial();
    ver.isActive = true;
    ver.createdAt = now;

    versionRepo.save(ver);

    return CommandResult(true, cred.id, "");
  }

  CommandResult rotate(RotateKeyringRequest r) {
    auto cred = credRepo.findById(r.keyringId);
    if (cred.id.length == 0)
      return CommandResult(false, "", "Keyring not found");
    if (cred.type != CredentialType.keyring)
      return CommandResult(false, "", "Credential is not a keyring");
    if (cred.status != CredentialStatus.active)
      return CommandResult(false, "", "Keyring is not active");

    auto now = currentTimestamp();

    // Deactivate all current versions
    versionRepo.deactivateAll(cred.id);

    // Create new version
    auto versionCount = versionRepo.countByKeyring(cred.id);

    KeyringVersion ver;
    ver.id = randomUUID().to!string;
    ver.keyringId = cred.id;
    ver.tenantId = r.tenantId;
    ver.versionNumber = versionCount + 1;
    ver.keyMaterial = KeyringManager.generateKeyMaterial();
    ver.isActive = true;
    ver.createdAt = now;

    versionRepo.save(ver);

    cred.version_ = cred.version_ + 1;
    cred.updatedAt = now;
    credRepo.update(cred);

    return CommandResult(true, ver.id, "");
  }

  Credential get_(CredentialId id) {
    return credRepo.findById(id);
  }

  Credential[] listByNamespace(NamespaceId namespaceId) {
    return credRepo.findByNamespaceAndType(namespaceId, CredentialType.keyring);
  }

  KeyringVersion[] getVersions(CredentialId keyringId) {
    return versionRepo.findByKeyring(keyringId);
  }

  KeyringVersion getActiveVersion(CredentialId keyringId) {
    return versionRepo.findActiveVersion(keyringId);
  }

  CommandResult disable(CredentialId id) {
    auto cred = credRepo.findById(id);
    if (cred.id.length == 0)
      return CommandResult(false, "", "Keyring not found");

    cred.status = CredentialStatus.disabled;
    cred.updatedAt = currentTimestamp();
    credRepo.update(cred);
    return CommandResult(true, cred.id, "");
  }

  CommandResult remove(CredentialId id) {
    auto cred = credRepo.findById(id);
    if (cred.id.length == 0)
      return CommandResult(false, "", "Keyring not found");

    // Protection: must be disabled for 7+ days
    if (cred.status != CredentialStatus.disabled)
      return CommandResult(false, "", "Keyring must be disabled before deletion");

    if (!KeyringManager.canDelete(cred.updatedAt, currentTimestamp()))
      return CommandResult(false, "", "Keyring must be disabled for at least 7 days before deletion");

    versionRepo.removeByKeyring(id);
    credRepo.remove(id);
    return CommandResult(true, id, "");
  }

  private static long currentTimestamp() {
    import std.datetime.systime : Clock;

    return Clock.currStdTime();
  }
}
