/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.customers;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

class ManageCustomersUseCase { // TODO: UIMUseCase {
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

    Customer[] listCustomers(TenantId tenantId, CustomerType customerType) {
        return repo.findByType(tenantId, customerType);
    }

    CommandResult createCustomer(CustomerDTO dto) {
        Customer customer;
        customer.initEntity(dto.tenantId, dto.createdBy);
        customer.id = dto.customerId;
        customer.name = dto.name;
        customer.description = dto.description;
        customer.contactPerson = dto.contactPerson;
        customer.email = dto.email;
        customer.phone = dto.phone;
        customer.address = dto.address;
        customer.latitude = dto.latitude;
        customer.longitude = dto.longitude;
        customer.website = dto.website;
        customer.industry = dto.industry;
        customer.accountNumber = dto.accountNumber;
        if (!FieldServiceValidator.isValidCustomer(customer))
            return CommandResult(false, "", "Invalid customer data");
        repo.save(customer);
        return CommandResult(true, customer.id.value, "");
    }

    CommandResult updateCustomer(CustomerDTO dto) {
        auto customer = repo.findById(dto.tenantId, dto.customerId);
        if (customer.isNull)
            return CommandResult(false, "", "Customer not found");

        if (dto.name.length > 0)
            customer.name = dto.name;
        if (dto.description.length > 0)
            customer.description = dto.description;
        if (dto.contactPerson.length > 0)
            customer.contactPerson = dto.contactPerson;
        if (dto.email.length > 0)
            customer.email = dto.email;
        if (dto.phone.length > 0)
            customer.phone = dto.phone;
        if (dto.address.length > 0)
            customer.address = dto.address;
        if (!dto.updatedBy.isNull)
            customer.updatedBy = dto.updatedBy;
        repo.update(customer);
        return CommandResult(true, customer.id.value, "");
    }

    CommandResult deleteCustomer(TenantId tenantId, CustomerId id) {
        auto customer = repo.findById(tenantId, id);
        if (customer.isNull)
            return CommandResult(false, "", "Customer not found");

        repo.remove(customer);
        return CommandResult(true, customer.id.value, "");
    }
}
