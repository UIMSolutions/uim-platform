/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.business_roles;

// import uim.platform.abap_environment.domain.entities.business_role;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - business role persistence.
interface BusinessRoleRepository : ITenantRepository!(BusinessRole, BusinessRoleId) {

  bool existsByName(SystemInstanceId systemId, string name);
  BusinessRole findByName(SystemInstanceId systemId, string name);
  void removeByName(SystemInstanceId systemId, string name);

  size_t countBySystem(SystemInstanceId systemId);
  BusinessRole[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

}
