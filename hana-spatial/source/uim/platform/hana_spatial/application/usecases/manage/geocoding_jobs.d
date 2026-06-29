/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.geocoding_jobs;

import uim.platform.hana_spatial;


// mixin(ShowModule!());

@safe:
class ManageGeocodingJobsUseCase {
  private GeocodingJobRepository repo;

  this(GeocodingJobRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateGeocodingJobRequest r) {
    auto err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateName(r.name);
    if (err.length > 0) return CommandResult(false, "", err);

    GeocodingJob job;
    job.initEntity(r.tenantId);
    job.id = GeocodingJobId(r.id);
    job.name = r.name;
    job.description = r.description;
    job.providerId = r.providerId;
    job.language = r.language;
    job.countryCode = r.countryCode;
    job.status = SpatialJobStatus.pending;
    job.totalItems = r.addresses.length;
    job.processedItems = 0;
    job.failedItems = 0;

    foreach (i, addr; r.addresses) {
      GeocodingJobItem item;
      item.inputAddress = addr;
      item.externalRef = i < r.externalRefs.length ? r.externalRefs[i] : "";
      item.processed = false;
      job.items ~= item;
    }

    repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult performAction(GeocodingJobActionRequest r) {
    auto existing = repo.findById(r.tenantId, GeocodingJobId(r.id));
    if (existing.isNull)
      return CommandResult(false, "", "Geocoding job not found");

    switch (r.action) {
      case "start":
        if (existing.status == SpatialJobStatus.pending)
          existing.status = SpatialJobStatus.processing;
        break;
      case "cancel":
        existing.status = SpatialJobStatus.cancelled;
        break;
      default:
        return CommandResult(false, "", "Unknown action: " ~ r.action);
    }

    existing.updatedAt = currentTimestamp;
    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  GeocodingJob getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, GeocodingJobId(id));
  }

  GeocodingJob[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, GeocodingJobId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Geocoding job not found");
    repo.remove(tenantId, GeocodingJobId(id));
    return CommandResult(true, id, "");
  }
}
