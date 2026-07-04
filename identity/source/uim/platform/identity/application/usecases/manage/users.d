/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.application.usecases.manage.users;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ManageUsersUseCase {
    private UserRepository repo;

    this(UserRepository repo) { this.repo = repo; }

    User getUser(TenantId tenantId, UserId id) { return repo.findById(tenantId, id); }
    User[] listUsers(TenantId tenantId) { return repo.findByTenant(tenantId); }
    User[] listByStatus(TenantId tenantId, UserStatus status) { return repo.findByStatus(tenantId, status); }
    User findByEmail(TenantId tenantId, string email) { return repo.findByEmail(tenantId, email); }

    CommandResult createUser(UserDTO dto) {
        import std.digest.sha : sha256Of, toHexString;
        auto u = User(dto.tenantId, dto.userId);
        u.userName = dto.userName;
        u.email = dto.email;
        u.displayName = dto.displayName;
        u.firstName = dto.firstName;
        u.lastName = dto.lastName;
        u.phoneNumber = dto.phoneNumber;
        u.language = dto.language.length > 0 ? dto.language : "en";
        u.locale = dto.locale.length > 0 ? dto.locale : "en_US";
        u.timeZone = dto.timeZone.length > 0 ? dto.timeZone : "UTC";

        if (dto.status.length > 0) {
            
            try { u.status = dto.status.to!UserStatus; } catch (Exception) { u.status = UserStatus.active; }
        }
        if (dto.type_.length > 0) {
            
            try { u.type_ = dto.type_.to!UserType; } catch (Exception) { u.type_ = UserType.employee; }
        }
        if (dto.password.length > 0) {
            u.passwordHash = sha256Of(dto.password).toHexString.idup;
        }

        if (!IdentityValidator.isValidUser(u))
            return CommandResult(false, "", "Invalid user: userName and email are required");

        repo.save(u);
        return CommandResult(true, u.id.value, "");
    }

    CommandResult updateUser(UserDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.userId);
        if (existing.isNull) return CommandResult(false, "", "User not found");

        if (dto.displayName.length > 0) existing.displayName = dto.displayName;
        if (dto.firstName.length > 0) existing.firstName = dto.firstName;
        if (dto.lastName.length > 0) existing.lastName = dto.lastName;
        if (dto.phoneNumber.length > 0) existing.phoneNumber = dto.phoneNumber;
        if (dto.language.length > 0) existing.language = dto.language;
        if (dto.locale.length > 0) existing.locale = dto.locale;
        if (dto.timeZone.length > 0) existing.timeZone = dto.timeZone;
        if (dto.status.length > 0) {
            
            try { existing.status = dto.status.to!UserStatus; } catch (Exception) {}
        }
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteUser(TenantId tenantId, UserId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull) return CommandResult(false, "", "User not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
