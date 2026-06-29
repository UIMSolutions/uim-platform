/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.application.usecases.manage.business_partners;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class ManageBusinessPartnersUseCase {
    private BusinessPartnerRepository repo;

    this(BusinessPartnerRepository repo) {
        this.repo = repo;
    }

    BusinessPartner getBusinessPartner(TenantId tenantId, BusinessPartnerId id) {
        return repo.findById(tenantId, id);
    }

    BusinessPartner[] listBusinessPartners(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    BusinessPartner[] listByCategory(TenantId tenantId, BPCategory category) {
        return repo.findByCategory(tenantId, category);
    }

    BusinessPartner[] listByStatus(TenantId tenantId, BPStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    BusinessPartner[] listByCountry(TenantId tenantId, string country) {
        return repo.findByCountry(tenantId, country);
    }

    BusinessPartner[] search(TenantId tenantId, string searchTerm) {
        return repo.searchByName(tenantId, searchTerm);
    }

    CommandResult createBusinessPartner(BusinessPartnerDTO dto) {
        BusinessPartner bp;
        bp.initEntity(dto.tenantId, dto.createdBy);
        bp.id = dto.businessPartnerId;
        bp.bpNumber = dto.bpNumber;
        bp.email = dto.email;
        bp.phone = dto.phone;
        bp.mobile = dto.mobile;
        bp.fax = dto.fax;
        bp.website = dto.website;
        bp.firstName = dto.firstName;
        bp.lastName = dto.lastName;
        bp.title = dto.title;
        bp.gender = dto.gender;
        bp.dateOfBirth = dto.dateOfBirth;
        bp.nationality = dto.nationality;
        bp.organizationName = dto.organizationName;
        bp.organizationNameAdditional = dto.organizationNameAdditional;
        bp.industryCode = dto.industryCode;
        bp.industryDescription = dto.industryDescription;
        bp.street = dto.street;
        bp.houseNumber = dto.houseNumber;
        bp.postalCode = dto.postalCode;
        bp.city = dto.city;
        bp.region = dto.region;
        bp.country = dto.country;
        bp.addressType = dto.addressType;
        bp.taxNumber = dto.taxNumber;
        bp.vatNumber = dto.vatNumber;
        bp.taxJurisdiction = dto.taxJurisdiction;
        bp.roles = dto.roles;
        bp.bankAccountNumber = dto.bankAccountNumber;
        bp.bankRoutingNumber = dto.bankRoutingNumber;
        bp.bankName = dto.bankName;
        bp.bankCountry = dto.bankCountry;
        bp.externalBpId = dto.externalBpId;
        bp.sourceSystem = dto.sourceSystem;
        bp.searchTerms = dto.searchTerms;
        bp.language = dto.language;
        bp.validationStatus = ValidationStatus.notValidated;

        if (!MasterdataGovernanceValidator.isValidBusinessPartner(bp))
            return CommandResult(false, "", "Invalid business partner data");

        repo.save(bp);
        return CommandResult(true, bp.id.value, "");
    }

    CommandResult updateBusinessPartner(BusinessPartnerDTO dto) {
        auto bp = repo.findById(dto.tenantId, dto.businessPartnerId);
        if (bp.isNull)
            return CommandResult(false, "", "Business partner not found");

        if (dto.email.length > 0) bp.email = dto.email;
        if (dto.phone.length > 0) bp.phone = dto.phone;
        if (dto.mobile.length > 0) bp.mobile = dto.mobile;
        if (dto.fax.length > 0) bp.fax = dto.fax;
        if (dto.website.length > 0) bp.website = dto.website;
        if (dto.firstName.length > 0) bp.firstName = dto.firstName;
        if (dto.lastName.length > 0) bp.lastName = dto.lastName;
        if (dto.title.length > 0) bp.title = dto.title;
        if (dto.organizationName.length > 0) bp.organizationName = dto.organizationName;
        if (dto.industryCode.length > 0) bp.industryCode = dto.industryCode;
        if (dto.street.length > 0) bp.street = dto.street;
        if (dto.postalCode.length > 0) bp.postalCode = dto.postalCode;
        if (dto.city.length > 0) bp.city = dto.city;
        if (dto.country.length > 0) bp.country = dto.country;
        if (dto.taxNumber.length > 0) bp.taxNumber = dto.taxNumber;
        if (dto.vatNumber.length > 0) bp.vatNumber = dto.vatNumber;
        if (dto.roles.length > 0) bp.roles = dto.roles;
        if (dto.searchTerms.length > 0) bp.searchTerms = dto.searchTerms;
        if (!dto.updatedBy.isNull) bp.updatedBy = dto.updatedBy;
        bp.validationStatus = ValidationStatus.notValidated;

        repo.update(bp);
        return CommandResult(true, bp.id.value, "");
    }

    CommandResult deleteBusinessPartner(TenantId tenantId, BusinessPartnerId id) {
        auto bp = repo.findById(tenantId, id);
        if (bp.isNull)
            return CommandResult(false, "", "Business partner not found");

        repo.remove(bp);
        return CommandResult(true, bp.id.value, "");
    }
}
