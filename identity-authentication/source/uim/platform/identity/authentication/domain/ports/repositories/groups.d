/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.domain.ports.repositories.groups;
// import uim.platform.identity.authentication.domain.entities.group;
// import uim.platform.identity.authentication.domain.types;
import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// Port: outgoing — group persistence.
interface GroupRepository : ITenantRepository!(IdaGroup, GroupId) {
  
  bool existsByName(TenantId tenantId, string name);
  IdaGroup findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
}
