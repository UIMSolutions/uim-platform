/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.privatekey;
import uim.platform.foundry;

// mixin(ShowModule!());

@safe:
enum KeyAlgorithm {
    rsa2048,
    rsa4096,
    ecdsaP256,
    ecdsaP384,
}
KeyAlgorithm toKeyAlgorithm(string s) {
    const map = [
        "rsa2048": KeyAlgorithm.rsa2048,
        "rsa4096": KeyAlgorithm.rsa4096,
        "ecdsa-p256": KeyAlgorithm.ecdsaP256,
        "ecdsa-p384": KeyAlgorithm.ecdsaP384
    ];
    return map.get(s.toLower, KeyAlgorithm.rsa2048);
}

enum KeyStatus {
    active,
    inactive,
    deleted,
}
KeyStatus toKeyStatus(string s) {
    const map = [
        "active": KeyStatus.active,
        "inactive": KeyStatus.inactive,
        "deleted": KeyStatus.deleted
    ];
    return map.get(s.toLower, KeyStatus.inactive);
}