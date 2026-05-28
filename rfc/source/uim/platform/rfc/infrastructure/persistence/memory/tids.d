/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.persistence.memory.tids;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

class MemoryTidRepository : TidRepository {

    private Tid[string] _store;

    private static string _key(TenantId tenantId, TidValue value) {
        return tenantId ~ "|" ~ value;
    }

    override Tid findById(TenantId tenantId, TidValue value) {
        auto key = _key(tenantId, value);
        if (key !in _store) return Tid.init;
        return _store[key];
    }

    override Tid[] findByTenant(TenantId tenantId) {
        Tid[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId) result ~= _copy(kv.value);
        return result;
    }

    override Tid[] findByDestination(TenantId tenantId, DestinationId destId) {
        Tid[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.destinationId == destId)
                result ~= _copy(kv.value);
        return result;
    }

    override Tid[] findByStatus(TenantId tenantId, LuwStatus status) {
        Tid[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.status == status)
                result ~= _copy(kv.value);
        return result;
    }

    override bool save(Tid tid) {
        auto key = _key(tid.tenantId, tid.value);
        if (key in _store) return false;
        _store[key] = tid;
        return true;
    }

    override bool update(Tid tid) {
        auto key = _key(tid.tenantId, tid.value);
        if (key !in _store) return false;
        _store[key] = tid;
        return true;
    }

    override bool remove(TenantId tenantId, TidValue value) {
        auto key = _key(tenantId, value);
        if (key !in _store) return false;
        _store.remove(key);
        return true;
    }

    override size_t countByTenant(TenantId tenantId) {
        size_t n = 0;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId) n++;
        return n;
    }

private:
    static Tid _copy(ref const Tid src) {
        Tid t;
        t.value         = src.value;
        t.tenantId      = src.tenantId;
        t.destinationId = src.destinationId;
        t.status        = src.status;
        t.createdAt     = src.createdAt;
        t.updatedAt     = src.updatedAt;
        foreach (c; src.callIds) t.callIds ~= c;
        return t;
    }
}
