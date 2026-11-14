/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.services.cascade;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Removes everything that lives in a system when the system is deleted.
class CascadeDeleter {
  protected AbapRepositories repos;

  this(AbapRepositories repos) {
    this.repos = repos;
  }

  /// Delete all objects of a system. Transports from other systems that wait
  /// for an import into it fail. Returns the number of removed objects.
  size_t clearSystem(TenantId tenantId, SystemInstanceId systemId) {
    size_t removed;
    void clear(R)(R repo) {
      auto items = repo.findBySystem(tenantId, systemId);
      removed += items.length;
      if (items.length > 0)
        repo.remove(items);
    }

    clear(repos.applicationJobs);
    clear(repos.businessUsers);
    clear(repos.businessRoles);
    clear(repos.serviceBindings);
    clear(repos.communicationArrangements);
    clear(repos.softwareComponents);
    clear(repos.transportRequests);

    foreach (t; repos.transportRequests.findByTarget(tenantId, systemId)) {
      if (t.status == TransportStatus.imported)
        continue;
      if (t.status == TransportStatus.importing)
        t.status = TransportStatus.error;
      t.statusMessage = "Target system " ~ t.targetSystemName ~ " was deleted";
      t.targetSystemId = SystemInstanceId.init;
      t.targetSystemName = "";
      repos.transportRequests.update(t);
    }
    return removed;
  }
}
