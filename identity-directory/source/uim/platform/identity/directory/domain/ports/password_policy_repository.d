/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.password_policy_repository;

import uim.platform.identity.directory.domain.entities.password_policy;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — password policy persistence.
interface PasswordPolicyRepository
{
  PasswordPolicy findById(string id);
  PasswordPolicy findActiveForTenant(TenantId tenantId);
  PasswordPolicy[] findByTenant(TenantId tenantId);
  void save(PasswordPolicy policy);
  void update(PasswordPolicy policy);
  void remove(string id);
}
