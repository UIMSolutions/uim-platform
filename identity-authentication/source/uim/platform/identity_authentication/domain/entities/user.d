module uim.platform.identity_authentication.domain.entities.user;

import uim.platform.identity_authentication.domain.types;

/// Core user entity in the identity directory.
struct User
{
    UserId id;
    TenantId tenantId;
    string userName;
    string email;
    string firstName;
    string lastName;
    string passwordHash;
    UserStatus status = UserStatus.active;
    MfaType mfaType = MfaType.none;
    string mfaSecret;
    string[] groupIds;
    string phoneNumber;
    string externalIdpId;
    long createdAt;
    long updatedAt;
    string globalUserId; // Unique identifier across landscape (like SAP Global User ID)

    string displayName() const
    {
        return firstName ~ " " ~ lastName;
    }

    bool isActive() const
    {
        return status == UserStatus.active;
    }

    bool hasMfa() const
    {
        return mfaType != MfaType.none;
    }
}
