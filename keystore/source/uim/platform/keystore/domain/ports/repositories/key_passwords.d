/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.ports.repositories.key_passwords;
// import uim.platform.keystore.domain.entities.key_password;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;
mixin(ShowModule!());

@safe:

interface KeyPasswordRepository : ITenantRepository!(KeyPassword, KeyPasswordId) {

  bool existsByAlias(TenantId tenantId, string accountId, string applicationId, string alias_);
  KeyPassword findByAlias(TenantId tenantId, string accountId, string applicationId, string alias_);
  void removeByAlias(TenantId tenantId, string accountId, string applicationId, string alias_);

  size_t countByApplication(TenantId tenantId, string accountId, string applicationId);
  KeyPassword[] findByApplication(TenantId tenantId, string accountId, string applicationId);
  void removeByApplication(TenantId tenantId, string accountId, string applicationId);

}
