/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.entities.business_partner;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

struct BusinessPartner {
    mixin TenantEntity!(BusinessPartnerId);

    string bpNumber;
    BPCategory category = BPCategory.organization;
    BPStatus status = BPStatus.active;
    BPLegalForm legalForm = BPLegalForm.unknown;
    ValidationStatus validationStatus = ValidationStatus.notValidated;

    // Person-specific fields
    string firstName;
    string lastName;
    string title;
    string gender;
    string dateOfBirth;
    string nationality;

    // Organization-specific fields
    string organizationName;
    string organizationNameAdditional;
    string industryCode;
    string industryDescription;

    // Contact information
    string email;
    string phone;
    string mobile;
    string fax;
    string website;

    // Address
    string street;
    string houseNumber;
    string postalCode;
    string city;
    string region;
    string country;
    string addressType;

    // Tax information
    string taxNumber;
    string vatNumber;
    string taxJurisdiction;

    // Roles (comma-separated list of BPRole values)
    string roles;

    // Bank details
    string bankAccountNumber;
    string bankRoutingNumber;
    string bankName;
    string bankCountry;

    // Governance
    string externalBpId;
    string sourceSystem;
    int qualityScore;
    long lastReplicatedAt;
    string searchTerms;
    string language;

    Json toJson() const {
        return entityToJson
            .set("bpNumber", bpNumber)
            .set("category", category.to!string)
            .set("status", status.to!string)
            .set("legalForm", legalForm.to!string)
            .set("validationStatus", validationStatus.to!string)
            .set("firstName", firstName)
            .set("lastName", lastName)
            .set("title", title)
            .set("gender", gender)
            .set("dateOfBirth", dateOfBirth)
            .set("nationality", nationality)
            .set("organizationName", organizationName)
            .set("organizationNameAdditional", organizationNameAdditional)
            .set("industryCode", industryCode)
            .set("industryDescription", industryDescription)
            .set("email", email)
            .set("phone", phone)
            .set("mobile", mobile)
            .set("fax", fax)
            .set("website", website)
            .set("street", street)
            .set("houseNumber", houseNumber)
            .set("postalCode", postalCode)
            .set("city", city)
            .set("region", region)
            .set("country", country)
            .set("addressType", addressType)
            .set("taxNumber", taxNumber)
            .set("vatNumber", vatNumber)
            .set("taxJurisdiction", taxJurisdiction)
            .set("roles", roles)
            .set("bankAccountNumber", bankAccountNumber)
            .set("bankRoutingNumber", bankRoutingNumber)
            .set("bankName", bankName)
            .set("bankCountry", bankCountry)
            .set("externalBpId", externalBpId)
            .set("sourceSystem", sourceSystem)
            .set("qualityScore", qualityScore)
            .set("lastReplicatedAt", lastReplicatedAt)
            .set("searchTerms", searchTerms)
            .set("language", language);
    }
}
