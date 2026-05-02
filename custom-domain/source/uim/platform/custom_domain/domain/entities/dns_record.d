/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.dns_record;

// import uim.platform.custom_domain.domain.types;
import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
struct DnsRecord {
    mixin TenantEntity!(DnsRecordId);

    string customDomainId;
    DnsRecordType recordType;
    string hostname;
    string value;
    int ttl;
    DnsValidationStatus validationStatus;
    long lastValidatedAt;
    
    Json toJson() const {
        return entityToJson
            .set("customDomainId", customDomainId)
            .set("recordType", recordType.toString())
            .set("hostname", hostname)
            .set("value", value)
            .set("ttl", ttl)
            .set("validationStatus", validationStatus.toString())
            .set("lastValidatedAt", lastValidatedAt);
    }
}
