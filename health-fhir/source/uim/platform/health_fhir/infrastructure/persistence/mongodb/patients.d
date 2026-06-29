/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.mongodb.patients;

// MongoDB repository — requires vibe.d mongodb driver at runtime.
// Connection URI provided via HEALTHFHIR_MONGO_URI env variable.
// Implementation stub — extend with actual vibe.d MongoDB calls.
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class MongoPatientRepository : PatientRepository {
  private string collectionName = "fhir_patients";
  private string mongoUri;

  this(string mongoUri) {
    this.mongoUri = mongoUri;
  }

  // NOTE: Full MongoDB implementation requires @system vibe.d MongoDB client.
  // These stubs delegate to in-memory fallback for compilation correctness.
  // Replace with actual MongoDB CRUD using MongoClient when driver is available.

  private MemoryPatientRepository _fallback;

  private MemoryPatientRepository fallback() @trusted {
    if (_fallback is null) _fallback = new MemoryPatientRepository();
    return _fallback;
  }

  void save(Patient p) { fallback.save(p); }
  void update(Patient p) { fallback.update(p); }
  void remove(Patient p) { fallback.remove(p); }
  Patient[] findByTenant(TenantId tenantId) { return fallback.findByTenant(tenantId); }
  bool existsById(TenantId tenantId, PatientId id) { return fallback.existsById(tenantId, id); }
  Patient findById(TenantId tenantId, PatientId id) { return fallback.findById(tenantId, id); }
  void removeById(TenantId tenantId, PatientId id) { fallback.removeById(tenantId, id); }
  size_t countByTenant(TenantId tenantId) { return fallback.count(tenantId); }
  Patient[] findByTenantAll(TenantId tenantId) { return fallback.findByTenantAll(tenantId); }
  Patient[] searchByName(TenantId tenantId, string namePart) { return fallback.searchByName(tenantId, namePart); }
}
