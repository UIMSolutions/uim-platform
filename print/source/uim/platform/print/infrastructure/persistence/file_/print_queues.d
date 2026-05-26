/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File-based persistence for print queues.
/// Stores all entities as a JSON array at <dataDir>/print_queues.json.
module uim.platform.print.infrastructure.persistence.file_.print_queues;

import uim.platform.print;
import std.file : exists, readText, write;
import std.json;

mixin(ShowModule!());

@safe:

class FilePrintQueueRepository : PrintQueueRepository {
    private string dataDir;
    private PrintQueue[string] store;

    this(string dataDir) {
        this.dataDir = dataDir;
        loadFromFile();
    }

    // --- ITenantRepository implementation ---

    void save(PrintQueue entity) {
        store[entity.id.value] = entity;
        persist();
    }

    void update(PrintQueue entity) {
        store[entity.id.value] = entity;
        persist();
    }

    void remove(PrintQueue entity) {
        store.remove(entity.id.value);
        persist();
    }

    PrintQueue findById(TenantId tenantId, PrintQueueId id) {
        if (id.value in store && store[id.value].tenantId == tenantId)
            return store[id.value];
        return PrintQueue.init;
    }

    PrintQueue[] findByTenant(TenantId tenantId) {
        return store.values.filter!(q => q.tenantId == tenantId).array;
    }

    // --- PrintQueueRepository extra methods ---

    PrintQueue[] findByStatus(TenantId tenantId, PrintQueueStatus status) {
        return findByTenant(tenantId).filter!(q => q.status == status).array;
    }

    PrintQueue[] findByPrinter(TenantId tenantId, PrinterId printerId) {
        return findByTenant(tenantId).filter!(q => q.printerId == printerId).array;
    }

    PrintQueue findDefault(TenantId tenantId) {
        auto defaults = findByTenant(tenantId).filter!(q => q.isDefault).array;
        return defaults.length > 0 ? defaults[0] : PrintQueue.init;
    }

    // --- File I/O ---

    private string filePath() { return dataDir ~ "/print_queues.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            auto text = readText(filePath());
            auto jarr = parseJSON(text).array;
            foreach (j; jarr) {
                PrintQueue q;
                q.id = PrintQueueId(j["id"].str);
                q.tenantId = TenantId(j["tenantId"].str);
                q.name = j["name"].str;
                q.description = j["description"].str;
                q.printerId = PrinterId(j["printerId"].str);
                q.location = j["location"].str;
                q.costCenter = j["costCenter"].str;
                q.isDefault = j["isDefault"].boolean;
                q.maxRetries = cast(int) j["maxRetries"].integer;
                q.retentionDays = cast(int) j["retentionDays"].integer;
                import std.conv : to;
                q.status = j["status"].str.to!PrintQueueStatus;
                store[q.id.value] = q;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        JSONValue arr = JSONValue(cast(JSONValue[]) []);
        foreach (q; store.values) {
            JSONValue j;
            j["id"] = q.id.value;
            j["tenantId"] = q.tenantId.value;
            j["name"] = q.name;
            j["description"] = q.description;
            j["printerId"] = q.printerId.value;
            j["location"] = q.location;
            j["costCenter"] = q.costCenter;
            j["isDefault"] = q.isDefault;
            j["maxRetries"] = q.maxRetries;
            j["retentionDays"] = q.retentionDays;
            import std.conv : to;
            j["status"] = q.status.to!string;
            arr.array ~= j;
        }
        write(filePath(), arr.toPrettyString());
    }
}
