/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.persistence.memory.function_modules;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

class MemoryFunctionModuleRepository : FunctionModuleRepository {

    private FunctionModule[string] _store;

    private static string _key(string tenantId, FunctionModuleId id) {
        return tenantId ~ "|" ~ id;
    }

    override FunctionModule findById(string tenantId, FunctionModuleId id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return FunctionModule.init;
        return _store[key];
    }

    override FunctionModule[] findByTenant(string tenantId) {
        FunctionModule[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId) {
                auto fm = FunctionModule.create(kv.value.id, kv.value.tenantId,
                                                kv.value.functionGroup, kv.value.shortText);
                fm.remoteEnabled = kv.value.remoteEnabled;
                fm.active        = kv.value.active;
                fm.createdAt     = kv.value.createdAt;
                fm.updatedAt     = kv.value.updatedAt;
                foreach (p; kv.value.parameters)
                    fm.parameters ~= RfcParameter(p.name, p.direction, p.typeName,
                                                   p.defaultValue, p.optional, p.description);
                result ~= fm;
            }
        return result;
    }

    override FunctionModule[] findByFunctionGroup(string tenantId, string functionGroup) {
        FunctionModule[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.functionGroup == functionGroup) {
                auto fm = FunctionModule.create(kv.value.id, kv.value.tenantId,
                                                kv.value.functionGroup, kv.value.shortText);
                fm.remoteEnabled = kv.value.remoteEnabled;
                fm.active        = kv.value.active;
                fm.createdAt     = kv.value.createdAt;
                fm.updatedAt     = kv.value.updatedAt;
                foreach (p; kv.value.parameters)
                    fm.parameters ~= RfcParameter(p.name, p.direction, p.typeName,
                                                   p.defaultValue, p.optional, p.description);
                result ~= fm;
            }
        return result;
    }

    override bool save(FunctionModule fm) {
        auto key = _key(fm.tenantId, fm.id);
        if (key in _store) return false;
        _store[key] = fm;
        return true;
    }

    override bool update(FunctionModule fm) {
        auto key = _key(fm.tenantId, fm.id);
        if (key !in _store) return false;
        _store[key] = fm;
        return true;
    }

    override bool remove(string tenantId, FunctionModuleId id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return false;
        _store.remove(key);
        return true;
    }

    override size_t countByTenant(string tenantId) {
        size_t n = 0;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId) n++;
        return n;
    }
}
