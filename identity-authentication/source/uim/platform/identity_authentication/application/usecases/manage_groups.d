module uim.platform.identity_authentication.application.usecases.manage_groups;

// import uim.platform.identity_authentication.domain.entities.group;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.group;
// import uim.platform.identity_authentication.domain.ports.user;
// import uim.platform.identity_authentication.application.dto;
// 
// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : canFind, remove;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: group management (CRUD + membership).
class ManageGroupsUseCase {
    private GroupRepository groupRepo;
    private UserRepository userRepo;

    this(GroupRepository groupRepo, UserRepository userRepo) {
        this.groupRepo = groupRepo;
        this.userRepo = userRepo;
    }

    GroupResponse createGroup(CreateGroupRequest req) {
        auto now = Clock.currStdTime();
        auto group = Group(
            randomUUID().toString(),
            req.tenantId,
            req.name,
            req.description,
            [],
            now,
            now
        );
        groupRepo.save(group);
        return GroupResponse(group.id, "");
    }

    Group getGroup(GroupId id) {
        return groupRepo.findById(id);
    }

    Group[] listGroups(TenantId tenantId, uint offset = 0, uint limit = 100) {
        return groupRepo.findByTenant(tenantId, offset, limit);
    }

    string addMember(GroupId groupId, UserId userId) {
        import uim.platform.identity_authentication.domain.entities.user : User;

        auto group = groupRepo.findById(groupId);
        if (group == Group.init)
            return "Group not found";

        auto user = userRepo.findById(userId);
        if (user == User.init)
            return "User not found";

        if (!group.memberUserIds.canFind(userId)) {
            group.memberUserIds ~= userId;
            group.updatedAt = Clock.currStdTime();
            groupRepo.update(group);

            // Also update user's groupIds
            if (!user.groupIds.canFind(groupId)) {
                user.groupIds ~= groupId;
                userRepo.update(user);
            }
        }
        return "";
    }

    string removeMember(GroupId groupId, UserId userId) {
        auto group = groupRepo.findById(groupId);
        if (group == Group.init)
            return "Group not found";

        string[] updated;
        foreach (mid; group.memberUserIds) {
            if (mid != userId)
                updated ~= mid;
        }
        group.memberUserIds = updated;
        group.updatedAt = Clock.currStdTime();
        groupRepo.update(group);
        return "";
    }

    string deleteGroup(GroupId id) {
        groupRepo.remove(id);
        return "";
    }
}
