/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.memory.patients;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class MemoryPatientRepository : TenantRepository!(Patient, PatientId), PatientRepository {

  bool existsById(TenantId tenantId, PatientId id) {
    return !findById(tenantId, id).isNull;
  }

  Patient findById(TenantId tenantId, PatientId id) {
    foreach (p; findByTenant(tenantId)) {
      if (p.id == id) return p;
    }
    return Patient.init;
  }

  void removeById(TenantId tenantId, PatientId id) {
    auto p = findById(tenantId, id);
    if (!p.isNull) remove(p);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  Patient[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  Patient[] searchByName(TenantId tenantId, string namePart) {
    import std.string : toLower, indexOf;
    auto lower = namePart.toLower;
    Patient[] results;
    foreach (p; findByTenant(tenantId)) {
      foreach (n; p.name_) {
        if (n.family_.toLower.indexOf(lower) >= 0) {
          results ~= p;
          break;
        }
        foreach (g; n.given_) {
          if (g.toLower.indexOf(lower) >= 0) {
            results ~= p;
            break;
          }
        }
      }
    }
    return results;
  }
}
