module application.use_cases.manage_business_roles;

import application.dto;
import domain.entities.business_role;
import domain.ports.business_role_repository;
import domain.types;

import std.conv : to;
import std.uuid : randomUUID;

/// Application service for business role management.
class ManageBusinessRolesUseCase
{
    private BusinessRoleRepository repo;

    this(BusinessRoleRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createRole(CreateBusinessRoleRequest req)
    {
        if (req.name.length == 0)
            return CommandResult("", "Role name is required");
        if (req.systemInstanceId.length == 0)
            return CommandResult("", "System instance ID is required");

        auto existing = repo.findByName(req.systemInstanceId, req.name);
        if (existing !is null)
            return CommandResult("", "Business role '" ~ req.name ~ "' already exists");

        auto id = randomUUID().toString();
        BusinessRole role;
        role.id = id;
        role.tenantId = req.tenantId;
        role.systemInstanceId = req.systemInstanceId;
        role.name = req.name;
        role.description = req.description;
        role.roleType = parseRoleType(req.roleType);
        role.restrictionTypes = req.restrictionTypes;
        role.assignedCatalogs = req.assignedCatalogs;

        import std.datetime.systime : Clock;
        role.createdAt = Clock.currStdTime();
        role.updatedAt = role.createdAt;

        repo.save(role);
        return CommandResult(id, "");
    }

    CommandResult updateRole(BusinessRoleId id, UpdateBusinessRoleRequest req)
    {
        auto role = repo.findById(id);
        if (role is null)
            return CommandResult("", "Business role not found");

        if (req.description.length > 0) role.description = req.description;
        if (req.roleType.length > 0) role.roleType = parseRoleType(req.roleType);
        if (req.restrictionTypes.length > 0) role.restrictionTypes = req.restrictionTypes;
        if (req.assignedCatalogs.length > 0) role.assignedCatalogs = req.assignedCatalogs;

        import std.datetime.systime : Clock;
        role.updatedAt = Clock.currStdTime();

        repo.update(*role);
        return CommandResult(id, "");
    }

    BusinessRole* getRole(BusinessRoleId id)
    {
        return repo.findById(id);
    }

    BusinessRole[] listRoles(SystemInstanceId systemId)
    {
        return repo.findBySystem(systemId);
    }

    CommandResult deleteRole(BusinessRoleId id)
    {
        auto role = repo.findById(id);
        if (role is null)
            return CommandResult("", "Business role not found");

        repo.remove(id);
        return CommandResult(id, "");
    }
}

private RoleType parseRoleType(string s)
{
    switch (s)
    {
    case "unrestricted": return RoleType.unrestricted;
    case "restricted": return RoleType.restricted;
    case "custom": return RoleType.custom;
    default: return RoleType.unrestricted;
    }
}
