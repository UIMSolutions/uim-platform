/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.application.usecases.manage_key_passwords;

// import uim.platform.keystore.domain.entities.key_password;
// import uim.platform.keystore.domain.ports.repositories.key_password_repository;
// import uim.platform.keystore.domain.types;
// import uim.platform.keystore.application.dto;

import uim.platform.keystore.application.dto;

mixin(ShowModule!());

@safe:

@safe:

class ManageKeyPasswordsUseCase {
  private KeyPasswordRepository repo;

  this(KeyPasswordRepository repo) {
    this.repo = repo;
  }

  // Store or overwrite a password for a given alias.
  CommandResult setPassword(SetPasswordRequest r) {
    if (r.alias_.length == 0)
      return CommandResult(false, "", "Alias is required");
    if (r.passwordValue.length == 0)
      return CommandResult(false, "", "Password value is required");

    auto now = currentTimestamp();

    auto existing = repo.findByAlias(r.accountId, r.applicationId, r.alias_);
    if (!existing.isNull) {
      existing.passwordValue = r.passwordValue;
      existing.updatedAt     = now;
      repo.update(existing);
      return CommandResult(true, existing.id, "");
    }

    KeyPassword kp;
    kp.id            = randomUUID().toString();
    kp.alias_        = r.alias_;
    kp.passwordValue = r.passwordValue;
    kp.accountId     = r.accountId;
    kp.applicationId = r.applicationId;
    kp.tenantId      = r.tenantId;
    kp.createdAt     = now;
    kp.updatedAt     = now;

    repo.save(kp);
    return CommandResult(true, kp.id, "");
  }

  // Retrieve a password by alias. Returns KeyPassword.init when not found.
  KeyPassword getPassword(string accountId, string applicationId, string alias_) {
    return repo.findByAlias(accountId, applicationId, alias_);
  }

  KeyPassword[] listByApplication(string accountId, string applicationId) {
    return repo.findByApplication(accountId, applicationId);
  }

  // Delete a stored password by alias.
  CommandResult deletePassword(string accountId, string applicationId, string alias_) {
    auto kp = repo.findByAlias(accountId, applicationId, alias_);
    if (kp.id.length == 0)
      return CommandResult(false, "", "Password not found");
    repo.removeByAlias(accountId, applicationId, alias_);
    return CommandResult(true, kp.id, "");
  }
}
