/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.project_members;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryProjectMemberRepository : ProjectMemberRepository {
    private ProjectMember[] store;

    bool existsById(ProjectMemberId id) {
        return store.any!(e => e.id == id);
    }

    ProjectMember findById(ProjectMemberId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ProjectMember.init;
    }

    ProjectMember[] findAll() { return store; }

    ProjectMember[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ProjectMember[] findByApplication(ApplicationId applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    ProjectMember[] findByRole(MemberRole role) {
        return store.filter!(e => e.role == role).array;
    }

    void save(ProjectMember entity) { store ~= entity; }

    void update(ProjectMember entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(ProjectMemberId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
