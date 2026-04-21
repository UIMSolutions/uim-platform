/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.private_keys;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface PrivateKeyRepository : ITenantRepository!(PrivateKey, PrivateKeyId) {
}
