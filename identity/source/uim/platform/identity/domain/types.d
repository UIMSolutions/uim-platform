/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain value types / IDs for the Identity Service.
module uim.platform.identity.domain.types;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

struct IDMGroupId {
    mixin(IdTemplate);
}

struct IdentityProviderId {
    mixin(IdTemplate);
}

struct ProvisioningJobId {
    mixin(IdTemplate);
}
