module domain.entities.group;

import domain.types;

/// Member reference within a group.
struct GroupMember
{
    string value; // user or group ID
    string type;  // "User" or "Group"
    string display;
}

/// SCIM 2.0 group entity.
struct Group
{
    GroupId id;
    TenantId tenantId;
    string externalId;
    string displayName;
    string description;
    GroupType groupType = GroupType.standard;
    GroupMember[] members;
    string[] schemas;
    long createdAt;
    long updatedAt;

    /// Number of members.
    ulong memberCount() const
    {
        return members.length;
    }

    /// Check if a user is a member.
    bool hasMember(string userId) const
    {
        foreach (m; members)
        {
            if (m.value == userId)
                return true;
        }
        return false;
    }
}
