/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.addresses;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class CleanseAddressesUseCase : DqInteractor, ICleanseAddresses {
  protected AddressCleanser cleanser;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
    cleanser = new AddressCleanser;
  }

  PostalAddress cleanseAddress(CleanseAddressRequest r) {
    foreach (v; [r.input.line1, r.input.line2, r.input.city, r.input.region, r.input.postalCode, r.input.country])
      requireMaxLength(v, 512, "PostalAddress field");
    PostalAddress a;
    auto at = now;
    stampCreated!(PostalAddress, AddressId)(a, r.tenantId, r.actor, newResourceId(), at);
    a.sourceRecordId = r.sourceRecordId.strip;
    a.input = r.input;
    a.output = cleanser.cleanse(r.input);
    a.cleansedAt = at;
    if (r.persist) {
      repos.addresses.save(a);
      emit("address.cleansed", r.tenantId, a.id.value, Json(["quality": Json(cast(string) a.output.quality)]));
    }
    return a;
  }

  PostalAddress getAddress(TenantId t, AddressId id) {
    return required(repos.addresses.findById(t, id), "Address '" ~ id.value ~ "'");
  }

  PostalAddress[] listAddresses(TenantId t) {
    return repos.addresses.findAll(t);
  }

  void deleteAddress(TenantId t, AddressId id) {
    getAddress(t, id);
    repos.addresses.removeById(t, id);
  }
}
