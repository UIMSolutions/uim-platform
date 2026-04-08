/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.services.domain_validator;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

struct DomainValidator {
    static string validate(string id, string name) {
        if (id.isEmpty)
            return "ID is required";
        if (name.length == 0)
            return "Name is required";
        if (name.length > 253)
            return "Domain name must be 253 characters or fewer";
        return "";
    }

    static string validateDomainName(string domainName) {
        if (domainName.length == 0)
            return "Domain name is required";
        if (domainName.length > 253)
            return "Domain name must be 253 characters or fewer";
        // Basic validation: must contain at least one dot
        bool hasDot = false;
        foreach (c; domainName) {
            if (c == '.') {
                hasDot = true;
                break;
            }
        }
        if (!hasDot)
            return "Domain name must contain at least one dot";
        return "";
    }
}
