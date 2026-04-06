/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.company_profile_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface CompanyProfileRepository {
    CompanyProfile[] findAll();
    CompanyProfile* findById(CompanyProfileId id);
    CompanyProfile[] findByTenant(TenantId tenantId);
    CompanyProfile[] findByType(CompanyType companyType);
    CompanyProfile[] findByStatus(CompanyStatus status);
    CompanyProfile[] findByName(string name);
    void save(CompanyProfile profile);
    void update(CompanyProfile profile);
    void remove(CompanyProfileId id);
}
