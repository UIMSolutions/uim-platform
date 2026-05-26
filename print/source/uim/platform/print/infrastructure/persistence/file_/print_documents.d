/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// File-based persistence for print documents.
module uim.platform.print.infrastructure.persistence.file_.print_documents;

import uim.platform.print;
import std.file : exists, readText, write;
import std.json;

mixin(ShowModule!());

@safe:

class FilePrintDocumentRepository : PrintDocumentRepository {
    private string dataDir;
    private PrintDocument[string] store;

    this(string dataDir) {
        this.dataDir = dataDir;
        loadFromFile();
    }

    void save(PrintDocument entity) { store[entity.id.value] = entity; persist(); }
    void update(PrintDocument entity) { store[entity.id.value] = entity; persist(); }
    void remove(PrintDocument entity) { store.remove(entity.id.value); persist(); }

    PrintDocument findById(TenantId tenantId, PrintDocumentId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return PrintDocument.init;
    }

    PrintDocument[] findByTenant(TenantId tenantId) {
        return store.values.filter!(d => d.tenantId == tenantId).array;
    }

    PrintDocument[] findByFormat(TenantId tenantId, DocumentFormat format) {
        return findByTenant(tenantId).filter!(d => d.format == format).array;
    }

    PrintDocument[] findExpired(TenantId tenantId, long nowTimestamp) {
        return findByTenant(tenantId)
            .filter!(d => d.expiresAt > 0 && d.expiresAt < nowTimestamp).array;
    }

    void removeExpired(TenantId tenantId, long nowTimestamp) {
        findExpired(tenantId, nowTimestamp).each!(d => remove(d));
    }

    private string filePath() { return dataDir ~ "/print_documents.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            import std.conv : to;
            foreach (j; parseJSON(readText(filePath())).array) {
                PrintDocument d;
                d.id = PrintDocumentId(j["id"].str);
                d.tenantId = TenantId(j["tenantId"].str);
                d.fileName = j["fileName"].str;
                d.mimeType = j["mimeType"].str;
                d.format = j["format"].str.to!DocumentFormat;
                d.sizeBytes = j["sizeBytes"].integer;
                d.storageUri = j["storageUri"].str;
                d.checksum = j["checksum"].str;
                d.expiresAt = j["expiresAt"].integer;
                store[d.id.value] = d;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        import std.conv : to;
        JSONValue arr = JSONValue(cast(JSONValue[]) []);
        foreach (d; store.values) {
            JSONValue j;
            j["id"] = d.id.value;
            j["tenantId"] = d.tenantId.value;
            j["fileName"] = d.fileName;
            j["mimeType"] = d.mimeType;
            j["format"] = d.format.to!string;
            j["sizeBytes"] = d.sizeBytes;
            j["storageUri"] = d.storageUri;
            j["checksum"] = d.checksum;
            j["expiresAt"] = d.expiresAt;
            arr.array ~= j;
        }
        write(filePath(), arr.toPrettyString());
    }
}
