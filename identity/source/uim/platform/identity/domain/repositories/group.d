/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.domain.repositories.group;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

interface GroupRepository {
    void save(Group entity);
    void update(Group entity);
    void remove(Group entity);
    Group findById(TenantId tenantId, GroupId id);
    Group[] findByTenant(TenantId tenantId);
    Group findByName(TenantId tenantId, string name);
    Group[] findByType(TenantId tenantId, GroupType type_);
    Group[] findByMember(TenantId tenantId, UserId userId);
}
