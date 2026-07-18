/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.persistence.repositories.calls;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

class MemoryRfcCallRepository : RfcCallRepository {

    private RfcCall[string] _store;

    private static string _key(TenantId tenantId, RfcCallId id) {
        return tenantId ~ "|" ~ id;
    }

    override RfcCall findById(TenantId tenantId, RfcCallId id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return RfcCall.init;
        return _store[key];
    }

    override RfcCall[] findByTenant(TenantId tenantId) {
        RfcCall[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId) result ~= _copy(kv.value);
        return result;
    }

    override RfcCall[] findByDestination(TenantId tenantId, DestinationId destId) {
        RfcCall[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.destinationId == destId)
                result ~= _copy(kv.value);
        return result;
    }

    override RfcCall[] findByTid(TenantId tenantId, TidValue tid) {
        RfcCall[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.tid == tid)
                result ~= _copy(kv.value);
        return result;
    }

    override RfcCall[] findByStatus(TenantId tenantId, RfcStatus status) {
        RfcCall[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.status == status)
                result ~= _copy(kv.value);
        return result;
    }

    override bool save(RfcCall call) {
        auto key = _key(call.tenantId, call.id);
        if (key in _store) return false;
        _store[key] = call;
        return true;
    }

    override bool update(RfcCall call) {
        auto key = _key(call.tenantId, call.id);
        if (key !in _store) return false;
        _store[key] = call;
        return true;
    }

    override bool remove(TenantId tenantId, RfcCallId id) {
        auto key = _key(tenantId, id);
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
    static RfcCall _copy(ref const RfcCall src) {
        RfcCall c;
        c.id             = src.id;
        c.tenantId       = src.tenantId;
        c.destinationId  = src.destinationId;
        c.functionModule = src.functionModule;
        c.rfcType        = src.rfcType;
        c.status         = src.status;
        c.tid            = src.tid;
        c.queueName      = src.queueName;
        c.errorMessage   = src.errorMessage;
        c.createdAt      = src.createdAt;
        c.executedAt     = src.executedAt;
        c.completedAt    = src.completedAt;
        foreach (p; src.importParams)   c.importParams   ~= ParameterValue(p.name, p.value);
        foreach (p; src.exportParams)   c.exportParams   ~= ParameterValue(p.name, p.value);
        foreach (p; src.changingParams) c.changingParams ~= ParameterValue(p.name, p.value);
        return c;
    }
}
