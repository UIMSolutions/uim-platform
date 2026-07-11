/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.repositories.groups;
// import uim.platform.identity_authentication.domain.entities.group;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.group;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for group persistence.
class MemoryGroupRepository : TenantRepository!(IdaGroup, GroupId), GroupRepository {

    bool existsByName(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }

    IdaGroup findByName(TenantId tenantId, string name) {
        foreach (e; findByTenant(tenantId)) {
            if (e.name == name) {
                return e;
            }
        }
        return IdaGroup.init;
    }

    void removeByName(TenantId tenantId, string name) {
        foreach (e; findByTenant(tenantId)) {
            if (e.name == name) {
                remove(e);
                return;
            }
        }
    }

}
