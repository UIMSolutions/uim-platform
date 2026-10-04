/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.domain.ports.repositories.user;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

interface IUserRepository : ITenantRepository!(IdmUser, UserId) {

    IdmUser findByUserName(TenantId tenantId, string userName);
    IdmUser findByEmail(TenantId tenantId, string email);
    IdmUser[] findByStatus(TenantId tenantId, UserStatus status);
    IdmUser[] findByType(TenantId tenantId, UserType type_);
    IdmUser[] findByGroup(TenantId tenantId, IDMGroupId groupId);

}
