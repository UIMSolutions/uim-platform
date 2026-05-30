/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.application.usecases.manage.groups;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ManageGroupsUseCase {
    private GroupRepository repo;

    this(GroupRepository repo) { this.repo = repo; }

    Group getGroup(TenantId tenantId, GroupId id) { return repo.findById(tenantId, id); }
    Group[] listGroups(TenantId tenantId) { return repo.findByTenant(tenantId); }
    Group[] listByType(TenantId tenantId, GroupType type_) { return repo.findByType(tenantId, type_); }

    CommandResult createGroup(GroupDTO dto) {
        Group g;
        g.initEntity(dto.tenantId, dto.createdBy);
        g.id = dto.groupId;
        g.name = dto.name;
        g.description = dto.description;
        if (dto.type_.length > 0) {
            
            try { g.type_ = dto.type_.to!GroupType; } catch (Exception) { g.type_ = GroupType.userGroup; }
        }
        g.memberIds = dto.memberIds;

        if (!IdentityValidator.isValidGroup(g))
            return CommandResult(false, "", "Invalid group: name is required");

        repo.save(g);
        return CommandResult(true, g.id.value, "");
    }

    CommandResult updateGroup(GroupDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.groupId);
        if (existing.isNull) return CommandResult(false, "", "Group not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.memberIds.length > 0) existing.memberIds = dto.memberIds;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult addMember(TenantId tenantId, GroupId groupId, UserId userId) {
        auto g = repo.findById(tenantId, groupId);
        if (g.isNull) return CommandResult(false, "", "Group not found");
        import std.algorithm : canFind;
        if (!g.memberIds.canFind(userId.value))
            g.memberIds ~= userId.value;
        repo.update(g);
        return CommandResult(true, groupId.value, "");
    }

    CommandResult removeMember(TenantId tenantId, GroupId groupId, UserId userId) {
        auto g = repo.findById(tenantId, groupId);
        if (g.isNull) return CommandResult(false, "", "Group not found");
        import std.algorithm : filter;
        import std.array : array;
        g.memberIds = g.memberIds.filter!(m => m != userId.value).array;
        repo.update(g);
        return CommandResult(true, groupId.value, "");
    }

    CommandResult deleteGroup(TenantId tenantId, GroupId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull) return CommandResult(false, "", "Group not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
