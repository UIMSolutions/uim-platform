/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.ports.repositories.key_password_repository;

import uim.platform.keystore.domain.entities.key_password;
import uim.platform.keystore.domain.types;

@safe:

interface KeyPasswordRepository {
  bool existsByAlias(string accountId, string applicationId, string alias_);
  KeyPassword findByAlias(string accountId, string applicationId, string alias_);

  KeyPassword[] findByApplication(string accountId, string applicationId);

  void save(KeyPassword kp);
  void update(KeyPassword kp);
  void removeByAlias(string accountId, string applicationId, string alias_);

  size_t countByApplication(string accountId, string applicationId);
}
