/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.files.patients;

import std.file : exists, mkdirRecurse, write, readText, dirEntries, SpanMode, remove;
import std.path : buildPath, baseName, stripExtension;
import std.array : array;
import vibe.data.json;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

/// File-backed Patient repository — stores one JSON file per resource
class FilePatientRepository : PatientRepository {
  private string basePath;

  this(string basePath) {
    this.basePath = basePath;
    () @trusted { mkdirRecurse(basePath); }();
  }

  private string filePath(TenantId tenantId, PatientId id) {
    return buildPath(basePath, "Patient_" ~ tenantId.value ~ "_" ~ id.value ~ ".json");
  }

  private Patient[] allForTenant(TenantId tenantId) @trusted {
    Patient[] result;
    auto pattern = "Patient_" ~ tenantId.value ~ "_";
    foreach (entry; dirEntries(basePath, SpanMode.shallow)) {
      auto name = baseName(entry.name);
      if (name.length > pattern.length && name[0 .. pattern.length] == pattern) {
        try {
          auto j = parseJsonString(readText(entry.name));
          Patient p = jsonToPatient(j);
          result ~= p;
        } catch (Exception) {}
      }
    }
    return result;
  }

  private static Patient jsonToPatient(Json j) {
    Patient p;
    p.id = PatientId(j["id"].get!string);
    p.tenantId = TenantId(j.get!Json.get("tenantId", Json("")).get!string);
    p.active_ = j.get!Json.get("active", Json(false)).get!bool;
    p.birthDate_ = j.get!Json.get("birthDate", Json("")).get!string;
    return p;
  }

  void save(Patient p) @trusted {
    auto path = filePath(p.tenantId, p.id);
    write(path, p.toJson().toString());
  }

  void update(Patient p) @trusted {
    save(p);
  }

  void remove(Patient p) @trusted {
    auto path = filePath(p.tenantId, p.id);
    if (exists(path)) std.file.remove(path);
  }

  Patient[] findByTenant(TenantId tenantId) {
    return allForTenant(tenantId);
  }

  bool existsById(TenantId tenantId, PatientId id) {
    return () @trusted { return exists(filePath(tenantId, id)); }();
  }

  Patient findById(TenantId tenantId, PatientId id) {
    auto path = filePath(tenantId, id);
    if (!() @trusted { return exists(path); }()) return Patient.init;
    try {
      auto j = parseJsonString(() @trusted { return readText(path); }());
      return jsonToPatient(j);
    } catch (Exception) { return Patient.init; }
  }

  void removeById(TenantId tenantId, PatientId id) {
    auto path = filePath(tenantId, id);
    () @trusted { if (exists(path)) std.file.remove(path); }();
  }

  size_t countByTenant(TenantId tenantId) {
    return allForTenant(tenantId).length;
  }

  Patient[] findByTenantAll(TenantId tenantId) {
    return allForTenant(tenantId);
  }

  Patient[] searchByName(TenantId tenantId, string namePart) {
    import std.string : toLower, indexOf;
    auto lower = namePart.toLower;
    Patient[] results;
    foreach (p; allForTenant(tenantId)) {
      foreach (n; p.name_) {
        if (n.family_.toLower.indexOf(lower) >= 0) {
          results ~= p;
          break;
        }
      }
    }
    return results;
  }
}
