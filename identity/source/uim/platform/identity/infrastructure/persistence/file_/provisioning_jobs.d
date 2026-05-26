/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.file_.provisioning_jobs;

import uim.platform.identity;
import std.file : exists, readText, write;
import std.json;

mixin(ShowModule!());

@safe:

class FileProvisioningJobRepository : ProvisioningJobRepository {
    private string dataDir;
    private ProvisioningJob[string] store;

    this(string dataDir) { this.dataDir = dataDir; loadFromFile(); }

    void save(ProvisioningJob entity) { store[entity.id.value] = entity; persist(); }
    void update(ProvisioningJob entity) { store[entity.id.value] = entity; persist(); }
    void remove(ProvisioningJob entity) { store.remove(entity.id.value); persist(); }

    ProvisioningJob findById(TenantId tenantId, ProvisioningJobId id) {
        if (id.value in store && store[id.value].tenantId == tenantId) return store[id.value];
        return ProvisioningJob.init;
    }
    ProvisioningJob[] findByTenant(TenantId tenantId) {
        return store.values.filter!(j => j.tenantId == tenantId).array;
    }
    ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status) {
        return findByTenant(tenantId).filter!(j => j.status == status).array;
    }
    ProvisioningJob[] findByType(TenantId tenantId, JobType type_) {
        return findByTenant(tenantId).filter!(j => j.type_ == type_).array;
    }
    ProvisioningJob[] findByTargetSystem(TenantId tenantId, string targetSystem) {
        return findByTenant(tenantId).filter!(j => j.targetSystem == targetSystem).array;
    }

    private string filePath() { return dataDir ~ "/provisioning_jobs.json"; }

    private void loadFromFile() @trusted {
        if (!filePath().exists) return;
        try {
            import std.conv : to;
            foreach (jv; parseJSON(readText(filePath())).array) {
                ProvisioningJob j;
                j.id = ProvisioningJobId(jv["id"].str);
                j.tenantId = TenantId(jv["tenantId"].str);
                j.name = jv["name"].str;
                j.sourceSystem = jv["sourceSystem"].str;
                j.targetSystem = jv["targetSystem"].str;
                j.type_ = jv["type"].str.to!JobType;
                j.status = jv["status"].str.to!JobStatus;
                store[j.id.value] = j;
            }
        } catch (Exception) {}
    }

    private void persist() @trusted {
        import std.conv : to;
        JSONValue[] arr;
        foreach (j; store.values) {
            arr ~= JSONValue(["id": JSONValue(j.id.value), "tenantId": JSONValue(j.tenantId.value),
                "name": JSONValue(j.name), "sourceSystem": JSONValue(j.sourceSystem),
                "targetSystem": JSONValue(j.targetSystem), "type": JSONValue(j.type_.to!string),
                "status": JSONValue(j.status.to!string)]);
        }
        write(filePath(), JSONValue(arr).toString());
    }
}
