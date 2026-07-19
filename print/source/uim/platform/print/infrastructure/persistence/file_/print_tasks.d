/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File-based persistence for print tasks.
module uim.platform.print.infrastructure.persistence.file_.print_tasks;

import uim.platform.print;
import std.file : exists, readText, write;
import std.json;

mixin(ShowModule!());

@safe:

class FilePrintTaskRepository : PrintTaskRepository {
    private string dataDir;
    private PrintTask[string] store;

    this(string dataDir) {
        this.dataDir = dataDir;
        loadFromFile();
    }

    void save(PrintTask entity) { store[entity.id.value] = entity; persist(); }
    void update(PrintTask entity) { store[entity.id.value] = entity; persist(); }
    void remove(PrintTask entity) { store.remove(entity.id.value); persist(); }

    PrintTask findById(TenantId tenantId, PrintTaskId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return PrintTask.init;
    }

    PrintTask[] findByTenant(TenantId tenantId) {
        return store.values.filter!(t => t.tenantId == tenantId).array;
    }

    PrintTask[] findByQueue(TenantId tenantId, PrintQueueId queueId) {
        return findByTenant(tenantId).filter!(t => t.queueId == queueId).array;
    }

    PrintTask[] findByStatus(TenantId tenantId, PrintTaskStatus status) {
        return findByTenant(tenantId).filter!(t => t.status == status).array;
    }

    PrintTask[] findPendingByQueue(TenantId tenantId, PrintQueueId queueId) {
        return findByTenant(tenantId)
            .filter!(t => t.queueId == queueId && t.status == PrintTaskStatus.pending).array;
    }

    size_t countByStatus(TenantId tenantId, PrintTaskStatus status) {
        return findByStatus(tenantId, status).length;
    }

    private string filePath() { return dataDir ~ "/print_tasks.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            auto text = readText(filePath());
            
            foreach (j; parseJSON(text).array) {
                PrintTask t;
                t.id = PrintTaskId(j["id"].str);
                t.tenantId = TenantId(j["tenantId"].str);
                t.queueId = PrintQueueId(j["queueId"].str);
                t.documentId = PrintDocumentId(j["documentId"].str);
                t.applicationId = j["applicationId"].str;
                t.senderApplication = j["senderApplication"].str;
                t.copies = cast(int) j["copies"].integer;
                t.status = j["status"].str.to!PrintTaskStatus;
                store[t.id.value] = t;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        
        Json arr = Json(cast(Json) []);
        foreach (t; store.values) {
            Json j;
            j["id"] = t.id.value;
            j["tenantId"] = t.tenantId.value;
            j["queueId"] = t.queueId.value;
            j["documentId"] = t.documentId.value;
            j["applicationId"] = t.applicationId;
            j["senderApplication"] = t.senderApplication;
            j["copies"] = t.copies;
            j["status"] = t.status.to!string;
            arr.array ~= j;
        }
        write(filePath(), arr.toPrettyString());
    }
}
