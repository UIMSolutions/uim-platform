/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.announcements;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemoryAnnouncementRepository : AnnouncementRepository {
    private Announcement[] store;

    Announcement[] findAll() { return store; }

    Announcement* findById(AnnouncementId id) {
        foreach (ref a; store)
            if (a.id == id) return &a;
        return null;
    }

    Announcement[] findByTenant(TenantId tenantId) {
        Announcement[] result;
        foreach (ref a; store)
            if (a.tenantId == tenantId) result ~= a;
        return result;
    }

    Announcement[] findByPublisher(string publisherId) {
        Announcement[] result;
        foreach (ref a; store)
            if (a.publisherId == publisherId) result ~= a;
        return result;
    }

    Announcement[] findBySeverity(AnnouncementSeverity severity) {
        Announcement[] result;
        foreach (ref a; store)
            if (a.severity == severity) result ~= a;
        return result;
    }

    Announcement[] findByStatus(AnnouncementStatus status) {
        Announcement[] result;
        foreach (ref a; store)
            if (a.status == status) result ~= a;
        return result;
    }

    void save(Announcement announcement) { store ~= announcement; }

    void update(Announcement announcement) {
        foreach (ref a; store)
            if (a.id == announcement.id) { a = announcement; return; }
    }

    void remove(AnnouncementId id) {
        import std.algorithm : remove;
        store = store.remove!(a => a.id == id);
    }
}
