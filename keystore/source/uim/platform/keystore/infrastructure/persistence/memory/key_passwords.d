/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.memory.key_passwords;
// import uim.platform.keystore.domain.entities.key_password;
// import uim.platform.keystore.domain.ports.repositories.key_password_repository;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class MemoryKeyPasswordRepository : TenantRepository!(KeyPassword, KeyPasswordId), KeyPasswordRepository {

  bool existsByAlias(TenantId tenantId, string applicationId, string alias_) {
    return findByTenant(tenantId).any!(kp => kp.applicationId == applicationId && kp.alias_ == alias_);
  }

  KeyPassword findByAlias(TenantId tenantId, string applicationId, string alias_) {
    foreach (kp; findByTenant(tenantId)) {
      if (kp.applicationId == applicationId && kp.alias_ == alias_)
        return kp;
    }
    return KeyPassword.init;
  }

  void removeByAlias(TenantId tenantId, string applicationId, string alias_) {
    foreach (kp; findByTenant(tenantId)) {
      if (kp.applicationId == applicationId && kp.alias_ == alias_) {
        remove(kp);
        return;
      }
    }
  }

  // #region ByApplication
  size_t countByApplication(TenantId tenantId, string applicationId) {
    return findByApplication(tenantId, applicationId).length;
  }

  KeyPassword[] filterByApplication(KeyPassword[] passwords, string applicationId) {
    return passwords.filter!(kp => kp.applicationId == applicationId).array;
  }

  KeyPassword[] findByApplication(TenantId tenantId, string applicationId) {
    return filterByApplication(findByTenant(tenantId), applicationId);
  }

  void removeByApplication(TenantId tenantId, string applicationId) {
    findByApplication(tenantId, applicationId).each!(kp => remove(kp));
  }
  // #endregion ByApplication

}
