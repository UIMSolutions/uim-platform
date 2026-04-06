/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.company_profiles;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemoryCompanyProfileRepository : CompanyProfileRepository {
    private CompanyProfile[] store;

    CompanyProfile[] findAll() { return store; }

    CompanyProfile* findById(CompanyProfileId id) {
        foreach (ref cp; store)
            if (cp.id == id) return &cp;
        return null;
    }

    CompanyProfile[] findByTenant(TenantId tenantId) {
        CompanyProfile[] result;
        foreach (ref cp; store)
            if (cp.tenantId == tenantId) result ~= cp;
        return result;
    }

    CompanyProfile[] findByType(CompanyType companyType) {
        CompanyProfile[] result;
        foreach (ref cp; store)
            if (cp.companyType == companyType) result ~= cp;
        return result;
    }

    CompanyProfile[] findByStatus(CompanyStatus status) {
        CompanyProfile[] result;
        foreach (ref cp; store)
            if (cp.status == status) result ~= cp;
        return result;
    }

    CompanyProfile[] findByName(string name) {
        CompanyProfile[] result;
        foreach (ref cp; store)
            if (cp.name == name) result ~= cp;
        return result;
    }

    void save(CompanyProfile profile) { store ~= profile; }

    void update(CompanyProfile profile) {
        foreach (ref cp; store)
            if (cp.id == profile.id) { cp = profile; return; }
    }

    void remove(CompanyProfileId id) {
        import std.algorithm : remove;
        store = store.remove!(cp => cp.id == id);
    }
}
