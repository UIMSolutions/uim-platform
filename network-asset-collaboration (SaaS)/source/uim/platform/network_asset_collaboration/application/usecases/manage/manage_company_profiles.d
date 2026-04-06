/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.usecases.manage.manage_company_profiles;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class ManageCompanyProfilesUseCase : UIMUseCase {
    private CompanyProfileRepository repo;

    this(CompanyProfileRepository repo) {
        this.repo = repo;
    }

    CompanyProfile* get_(CompanyProfileId id) {
        return repo.findById(id);
    }

    CompanyProfile[] list() {
        return repo.findAll();
    }

    CompanyProfile[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CompanyProfile[] listByType(CompanyType companyType) {
        return repo.findByType(companyType);
    }

    CompanyProfile[] listByStatus(CompanyStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(CompanyProfileDTO dto) {
        CompanyProfile cp;
        cp.id = dto.id;
        cp.tenantId = dto.tenantId;
        cp.name = dto.name;
        cp.description = dto.description;
        cp.industry = dto.industry;
        cp.website = dto.website;
        cp.contactEmail = dto.contactEmail;
        cp.contactPhone = dto.contactPhone;
        cp.addressStreet = dto.addressStreet;
        cp.addressCity = dto.addressCity;
        cp.addressState = dto.addressState;
        cp.addressCountry = dto.addressCountry;
        cp.addressPostalCode = dto.addressPostalCode;
        cp.createdBy = dto.createdBy;
        if (!AssetValidator.isValidCompanyProfile(cp))
            return CommandResult(false, "", "Invalid company profile data");
        repo.save(cp);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(CompanyProfileDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Company profile not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.contactEmail.length > 0) existing.contactEmail = dto.contactEmail;
        if (dto.contactPhone.length > 0) existing.contactPhone = dto.contactPhone;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(CompanyProfileId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Company profile not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
