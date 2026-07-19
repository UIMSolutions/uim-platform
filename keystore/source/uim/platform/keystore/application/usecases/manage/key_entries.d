/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.application.usecases.manage.key_entries;
// import uim.platform.keystore.domain.entities.key_entry;
// import uim.platform.keystore.domain.ports.repositories.key_entry_repository;
// import uim.platform.keystore.domain.types;
// import uim.platform.keystore.application.dto;

import uim.platform.keystore;
mixin(ShowModule!());

@safe:

class ManageKeyEntriesUseCase {
  private KeyEntryRepository repo;

  this(KeyEntryRepository repo) {
    this.repo = repo;
  }

  // Import a key or certificate entry into a keystore.
  CommandResult importEntry(ImportKeyEntryRequest r) {
    if (r.alias_.length == 0)
      return CommandResult(false, "", "Alias is required");
    if (r.content.length == 0)
      return CommandResult(false, "", "Content is required");

    if (repo.existsByAlias(r.tenantId, r.keystoreId, r.alias_))
      return CommandResult(false, "", "An entry with this alias already exists in the keystore");

    KeyEntry entry;
    entry.id = randomUUID();
    entry.keystoreId = r.keystoreId;
    entry.alias_ = r.alias_;
    entry.entryType = r.entryType.to!KeyEntryType;
    entry.content = r.content;
    entry.format = r.format;
    entry.subject = r.subject;
    entry.issuer = r.issuer;
    entry.serialNumber = r.serialNumber;
    entry.notBefore = r.notBefore;
    entry.notAfter = r.notAfter;
    entry.createdAt = currentTimestamp();

    repo.save(entry);
    return CommandResult(true, entry.id.value, "");
  }

  KeyEntry getById(TenantId tenantId, KeyEntryId id) {
    return repo.findById(tenantId, id);
  }

  KeyEntry getByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_) {
    return repo.findByAlias(tenantId, keystoreId, alias_);
  }

  KeyEntry[] listByKeystore(TenantId tenantId, KeystoreId keystoreId) {
    return repo.findByKeystore(tenantId, keystoreId);
  }

  CommandResult deleteKeyEntry(TenantId tenantId, KeyEntryId id) {
    auto entry = repo.findById(tenantId, id);
    if (entry.isNull)
      return CommandResult(false, "", "Key entry not found");

    repo.remove(entry);
    return CommandResult(true, entry.id.value, "");
  }
}
