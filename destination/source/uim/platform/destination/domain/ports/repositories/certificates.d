/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.ports.repositories.certificates;
// import uim.platform.destination.domain.entities.certificate;

import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Port: outgoing — certificate persistence.
interface ICertificateRepository : ITenantRepository!(Certificate, CertificateId) {

  /// Checks if a certificate with the given name exists for the specified tenant and subaccount.
  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name);
  /// Finds a certificate by its name for the specified tenant and subaccount.
  Certificate findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  /// Removes a certificate by its name for the specified tenant and subaccount.
  void removeByName(TenantId tenantId, SubaccountId subaccountId, string name);

  /// Counts the number of certificates for the specified tenant and subaccount.
  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  /// Finds all certificates for the specified tenant and subaccount
  Certificate[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  /// Removes all certificates for the specified tenant and subaccount.
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId);

  /// Counts the number of certificates of a specific type for the specified tenant and subaccount.
  size_t countByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);
  /// Finds all certificates of a specific type for the specified tenant and subaccount.
  Certificate[] findByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);
  /// Removes all certificates of a specific type for the specified tenant and subaccount.
  void removeByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);

  /// Counts the number of certificates that are expiring before the specified timestamp for the given tenant.
  size_t countExpiring(TenantId tenantId, long beforeTimestamp);
  /// Finds all certificates that are expiring before the specified timestamp for the given tenant.
  Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp);
  /// Removes all certificates that are expiring before the specified timestamp for the given tenant.
  void removeExpiring(TenantId tenantId, long beforeTimestamp);

}
