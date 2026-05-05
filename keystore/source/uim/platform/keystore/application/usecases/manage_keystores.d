/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.application.usecases.manage_keystores;

// import uim.platform.keystore.domain.entities.keystore_entity;
// import uim.platform.keystore.domain.ports.repositories.keystore_repository;
// import uim.platform.keystore.domain.types;
// import uim.platform.keystore.application.dto;

import uim.platform.keystore.application.dto;

mixin(ShowModule!());

@safe:

@safe:

class ManageKeystoresUseCase {
  private KeystoreRepository repo;

  this(KeystoreRepository repo) {
    this.repo = repo;
  }

  // Upload (create) a keystore at the given scope level.
  CommandResult upload(UploadKeystoreRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Name is required");
    if (r.content.length == 0)
      return CommandResult(false, "", "Content is required");

    auto level = parseKeystoreLevel(r.level);

    if (repo.existsByName(r.accountId, r.applicationId, level, r.name))
      return CommandResult(false, "", "A keystore with this name already exists at the specified level");

    KeystoreEntity ks;
    ks.id            = randomUUID().toString();
    ks.name          = r.name;
    ks.description   = r.description;
    ks.format        = parseKeystoreFormat(r.format);
    ks.level         = level;
    ks.content       = r.content;
    ks.accountId     = r.accountId;
    ks.applicationId = r.applicationId;
    ks.subscriptionId = r.subscriptionId;
    ks.createdBy     = r.createdBy;
    ks.updatedBy    = r.createdBy;
    ks.createdAt     = currentTimestamp();
    ks.updatedAt     = ks.createdAt;

    repo.save(ks);
    return CommandResult(true, ks.id.value, "");
  }

  // Update description and/or content of an existing keystore.
  CommandResult update(KeystoreId id, UpdateKeystoreRequest r) {
    auto ks = repo.findById(id);
    if (ks.id.length == 0)
      return CommandResult(false, "", "Keystore not found");

    if (r.description.length > 0)
      ks.description = r.description;
    if (r.content.length > 0)
      ks.content = r.content;
    ks.updatedBy = r.updatedBy;
    ks.updatedAt  = currentTimestamp();

    repo.update(ks);
    return CommandResult(true, ks.id.value, "");
  }

  KeystoreEntity getById(KeystoreId id) {
    return repo.findById(id);
  }

  KeystoreEntity getByName(string accountId, string applicationId, string level, string name) {
    return repo.findByName(accountId, applicationId, parseKeystoreLevel(level), name);
  }

  KeystoreEntity[] listByAccount(string accountId) {
    return repo.findByAccount(accountId);
  }

  KeystoreEntity[] listByApplication(string accountId, string applicationId) {
    return repo.findByApplication(accountId, applicationId);
  }

  // Delete by ID
  CommandResult remove(KeystoreId id) {
    auto ks = repo.findById(id);
    if (ks.id.length == 0)
      return CommandResult(false, "", "Keystore not found");
    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }

  // Delete by name + scope (console-style delete-keystore command)
  CommandResult removeByName(string accountId, string applicationId, string level, string name) {
    auto ks = repo.findByName(accountId, applicationId, parseKeystoreLevel(level), name);
    if (ks.id.length == 0)
      return CommandResult(false, "", "Keystore not found");
    repo.removeByName(accountId, applicationId, parseKeystoreLevel(level), name);
    return CommandResult(true, ks.id.value, "");
  }
}
