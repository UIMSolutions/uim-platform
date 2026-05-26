/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.file_.audit_entry_repo;

import uim.platform.feature_flags;
import vibe.data.json : Json, parseJsonString;
import std.file       : exists, mkdirRecurse, append, readText, dirEntries, SpanMode;
import std.path       : buildPath;
import std.algorithm  : filter;
import std.array      : array;
import std.string     : splitLines;

mixin(ShowModule!());

@safe:

/// Appends audit entries as NDJSON (one JSON object per line) to a per-tenant log file.
class FileAuditEntryRepository : AuditEntryRepository {
    private string basePath;

    this(string basePath) {
        this.basePath = buildPath(basePath, "_audit");
    }

    void append(AuditEntry entry) @trusted {
        ensureDir(entry.tenantId);
        auto line = toJson(entry).toString() ~ "\n";
        std.file.append(logPath(entry.tenantId), line);
    }

    AuditEntry[] findByTenant(TenantId tenantId) @trusted {
        auto p = logPath(tenantId);
        if (!p.exists) return [];
        return parseLog(readText(p));
    }

    AuditEntry[] findByEntity(TenantId tenantId, string entityId) {
        return findByTenant(tenantId).filter!(e => e.entityId == entityId).array;
    }

    AuditEntry[] findByTenantPaged(TenantId tenantId, size_t offset, size_t limit) {
        auto all = findByTenant(tenantId);
        if (offset >= all.length) return [];
        auto end = offset + limit;
        if (end > all.length) end = all.length;
        return all[offset .. end];
    }

    private:

    void ensureDir(string tenantId) @trusted {
        auto dir = buildPath(basePath, tenantId);
        if (!dir.exists) mkdirRecurse(dir);
    }

    string logPath(string tenantId) const {
        return buildPath(basePath, tenantId, "audit.ndjson");
    }

    AuditEntry[] parseLog(string text) {
        AuditEntry[] entries;
        foreach (line; text.splitLines()) {
            if (line.length == 0) continue;
            try {
                auto j = parseJsonString(line);
                AuditEntry e;
                e.id          = AuditEntryId(j["id"].get!string);
                e.tenantId    = j["tenantId"].get!string;
                import std.conv : to;
                e.action_     = j["action"].get!string.to!AuditAction;
                e.entityType  = j["entityType"].get!string;
                e.entityId    = j["entityId"].get!string;
                e.entityName  = j["entityName"].get!string;
                e.performedBy = j["performedBy"].get!string;
                e.performedAt = j["performedAt"].get!string;
                entries ~= e;
            } catch (Exception) {}
        }
        return entries;
    }
}
