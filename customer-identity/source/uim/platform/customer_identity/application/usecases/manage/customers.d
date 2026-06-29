/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.customers;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class ManageCustomersUseCase {
    private CustomerRepository repo;

    this(CustomerRepository repo) {
        this.repo = repo;
    }

    Customer getCustomer(TenantId tenantId, CustomerId id) {
        return repo.findById(tenantId, id);
    }

    Customer[] listCustomers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Customer findByEmail(TenantId tenantId, string email) {
        return repo.findByEmail(tenantId, email);
    }

    CommandResult registerCustomer(CustomerDTO dto) {
        if (repo.emailExists(dto.tenantId, dto.email))
            return CommandResult(false, "", "Email already registered");

        Customer c;
        c.initEntity(dto.tenantId, dto.createdBy);
        c.id = dto.customerId.value.length > 0 ? dto.customerId : CustomerId(c.id.value);
        c.email = dto.email;
        c.phone = dto.phone;
        c.firstName = dto.firstName;
        c.lastName = dto.lastName;
        c.passwordHash = dto.password;
        c.locale = dto.locale;
        c.country = dto.country;
        c.birthDate = dto.birthDate;
        c.profileData = dto.profileData;
        c.status = CustomerStatus.pending;

        if (!IdentityValidator.isValidCustomer(c))
            return CommandResult(false, "", "Invalid customer data");

        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    CommandResult updateCustomer(CustomerDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.customerId);
        if (existing.isNull)
            return CommandResult(false, "", "Customer not found");

        if (dto.firstName.length > 0) existing.firstName = dto.firstName;
        if (dto.lastName.length > 0) existing.lastName = dto.lastName;
        if (dto.phone.length > 0) existing.phone = dto.phone;
        if (dto.locale.length > 0) existing.locale = dto.locale;
        if (dto.country.length > 0) existing.country = dto.country;
        if (dto.birthDate.length > 0) existing.birthDate = dto.birthDate;
        if (dto.profileData.length > 0) existing.profileData = dto.profileData;
        if (dto.progressiveData.length > 0) existing.progressiveData = dto.progressiveData;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult activateCustomer(TenantId tenantId, CustomerId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Customer not found");

        existing.status = CustomerStatus.active;
        existing.emailVerified = true;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult lockCustomer(TenantId tenantId, CustomerId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Customer not found");

        existing.status = CustomerStatus.locked;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteCustomer(TenantId tenantId, CustomerId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Customer not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
