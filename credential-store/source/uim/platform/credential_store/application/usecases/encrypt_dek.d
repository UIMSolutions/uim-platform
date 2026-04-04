/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.use_cases.encrypt_dek;

import uim.platform.credential_store.domain.ports.credential_repository;
import uim.platform.credential_store.domain.ports.keyring_version_repository;
import uim.platform.credential_store.domain.entities.credential;
import uim.platform.credential_store.domain.entities.keyring_version;
import uim.platform.credential_store.domain.services.encryption_service;
import uim.platform.credential_store.domain.types;
import uim.platform.credential_store.application.dto;

class EncryptDekUseCase : UIMUseCase {
  private CredentialRepository credRepo;
  private KeyringVersionRepository versionRepo;

  this(CredentialRepository credRepo, KeyringVersionRepository versionRepo) {
    this.credRepo = credRepo;
    this.versionRepo = versionRepo;
  }

  // Generate a new DEK and return it both plaintext and encrypted
  GenerateDekResponse generate(GenerateDekRequest r) {
    auto keyring = credRepo.findByName(r.namespaceId, r.keyringName, CredentialType.keyring);
    if (keyring.id.length == 0)
      return GenerateDekResponse(false, "", "", "", 0, "Keyring not found");
    if (keyring.status != CredentialStatus.active)
      return GenerateDekResponse(false, "", "", "", 0, "Keyring is not active");

    auto activeVersion = versionRepo.findActiveVersion(keyring.id);
    if (activeVersion.id.length == 0)
      return GenerateDekResponse(false, "", "", "", 0, "No active keyring version");

    auto dek = EncryptionService.generateDek();
    auto encryptedDek = EncryptionService.encryptDek(dek, activeVersion.keyMaterial);

    return GenerateDekResponse(true, dek, encryptedDek, keyring.id, activeVersion.versionNumber, "");
  }

  // Encrypt a provided DEK with the active keyring version
  EncryptDekResponse encrypt(EncryptDekRequest r) {
    auto keyring = credRepo.findByName(r.namespaceId, r.keyringName, CredentialType.keyring);
    if (keyring.id.length == 0)
      return EncryptDekResponse(false, "", "", 0, "Keyring not found");
    if (keyring.status != CredentialStatus.active)
      return EncryptDekResponse(false, "", "", 0, "Keyring is not active");

    auto activeVersion = versionRepo.findActiveVersion(keyring.id);
    if (activeVersion.id.length == 0)
      return EncryptDekResponse(false, "", "", 0, "No active keyring version");

    auto encryptedDek = EncryptionService.encryptDek(r.dek, activeVersion.keyMaterial);

    return EncryptDekResponse(true, encryptedDek, keyring.id, activeVersion.versionNumber, "");
  }

  // Decrypt an encrypted DEK using the specified keyring version
  DecryptDekResponse decrypt(DecryptDekRequest r) {
    auto keyring = credRepo.findByName(r.namespaceId, r.keyringName, CredentialType.keyring);
    if (keyring.id.length == 0)
      return DecryptDekResponse(false, "", "Keyring not found");

    auto ver = versionRepo.findByVersion(keyring.id, r.keyringVersion);
    if (ver.id.length == 0)
      return DecryptDekResponse(false, "", "Keyring version not found");

    auto dek = EncryptionService.decryptDek(r.encryptedDek, ver.keyMaterial);

    return DecryptDekResponse(true, dek, "");
  }
}
