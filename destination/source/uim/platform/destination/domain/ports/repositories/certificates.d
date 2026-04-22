/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.ports.repositories.certificates;

// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Port: outgoing — certificate persistence.
interface CertificateRepository : ITenantRepository!(Certificate, CertificateId) {

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name);
  Certificate findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  void removeByName(TenantId tenantId, SubaccountId subaccountId, string name);

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Certificate[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId);

  size_t countByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);
  Certificate[] findByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);
  void removeByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);

  size_t countExpiring(TenantId tenantId, long beforeTimestamp);
  Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp);
  void removeExpiring(TenantId tenantId, long beforeTimestamp);

}
