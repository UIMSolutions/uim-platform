/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface DevSpaceRepository : ITenantRepository!(DevSpace, DevSpaceId) {

    size_t countByOwner(string owner);
    DevSpace[] findByOwner(string owner);
    void removeByOwner(string owner);

    size_t countByStatus(DevSpaceStatus status);
    DevSpace[] findByStatus(DevSpaceStatus status);
    void removeByStatus(DevSpaceStatus status);

}
