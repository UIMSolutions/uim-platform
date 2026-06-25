/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.application.dto;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

struct UserDTO {
    UserId userId;
    TenantId tenantId;
    string userName;
    string email;
    string displayName;
    string firstName;
    string lastName;
    string phoneNumber;
    string language;
    string locale;
    string timeZone;
    string status;
    string type_;
    string password;        // plain text only during creation, never stored
    UserId createdBy;
    UserId updatedBy;
}

struct GroupDTO {
    IDMGroupId groupId;
    TenantId tenantId;
    string name;
    string description;
    string type_;
    string[] memberIds;
    UserId createdBy;
    UserId updatedBy;
}

struct ApplicationDTO {
    ApplicationId applicationId;
    TenantId tenantId;
    string name;
    string description;
    string protocol;
    string status;
    string clientId;
    string[] redirectUris;
    string[] scopes;
    string authScheme;
    string logoUrl;
    string homepageUrl;
    bool multiTenantEnabled;
    bool riskBasedAuthEnabled;
    UserId createdBy;
    UserId updatedBy;
}

struct IdentityProviderDTO {
    IdentityProviderId idpId;
    TenantId tenantId;
    string name;
    string description;
    string type_;
    string status;
    string metadataUrl;
    string entityId;
    string ssoUrl;
    string sloUrl;
    string clientId;
    string[] allowedDomains;
    bool isDefault;
    UserId createdBy;
    UserId updatedBy;
}

struct ProvisioningJobDTO {
    ProvisioningJobId jobId;
    TenantId tenantId;
    string name;
    string description;
    string sourceSystem;
    string targetSystem;
    string type_;
    UserId createdBy;
}
