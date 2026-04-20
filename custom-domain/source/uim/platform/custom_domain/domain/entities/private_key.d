/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.private_key;

import uim.platform.custom_domain.domain.types;

struct PrivateKey {
    mixin TenantEntity!(PrivateKeyId);

    string subject;
    string[] domains;
    KeyAlgorithm algorithm;
    KeyStatus status;
    int keySize;
    string csrPem;
    string publicKeyFingerprint;
    
    Json toJson() const {
        auto j = entityToJson
            .set("subject", subject)
            .set("domains", domains)
            .set("algorithm", algorithm.to!string)
            .set("status", status.to!string)
            .set("keySize", keySize)
            .set("csrPem", csrPem)
            .set("publicKeyFingerprint", publicKeyFingerprint);

        return j;
    }
}
