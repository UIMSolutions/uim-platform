/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.customer;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Customer {
    CustomerId id;
    TenantId tenantId;
    string name;
    string description;
    CustomerType customerType = CustomerType.commercial;
    CustomerStatus status = CustomerStatus.active;
    string contactPerson;
    string email;
    string phone;
    string address;
    string latitude;
    string longitude;
    string website;
    string industry;
    string accountNumber;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
