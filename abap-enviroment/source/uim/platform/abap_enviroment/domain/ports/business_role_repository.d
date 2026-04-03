/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.business_role_repository;

import uim.platform.abap_enviroment.domain.entities.business_role;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - business role persistence.
interface BusinessRoleRepository
{
  BusinessRole* findById(BusinessRoleId id);
  BusinessRole[] findBySystem(SystemInstanceId systemId);
  BusinessRole[] findByTenant(TenantId tenantId);
  BusinessRole* findByName(SystemInstanceId systemId, string name);
  void save(BusinessRole role);
  void update(BusinessRole role);
  void remove(BusinessRoleId id);
}
