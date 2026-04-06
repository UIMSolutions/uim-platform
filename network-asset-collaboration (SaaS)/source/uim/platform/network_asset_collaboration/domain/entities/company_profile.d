/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.company_profile;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct CompanyProfile {
    CompanyProfileId id;
    TenantId tenantId;
    string name;
    string description;
    CompanyType companyType = CompanyType.operator;
    CompanyStatus status = CompanyStatus.pending;
    string industry;
    string website;
    string contactEmail;
    string contactPhone;
    string addressStreet;
    string addressCity;
    string addressState;
    string addressCountry;
    string addressPostalCode;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
