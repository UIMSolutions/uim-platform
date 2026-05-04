/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage.customers;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageCustomersUseCase { // TODO: UIMUseCase {
    private CustomerRepository repo;

    this(CustomerRepository repo) {
        this.repo = repo;
    }

    Customer getById(CustomerId id) {
        return repo.findById(id);
    }

    Customer[] list() {
        return repo.findAll();
    }

    Customer[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Customer[] listByType(CustomerType customerType) {
        return repo.findByType(customerType);
    }

    CommandResult create(CustomerDTO dto) {
        Customer c;
        c.id = dto.id;
        c.tenantId = dto.tenantId;
        c.name = dto.name;
        c.description = dto.description;
        c.contactPerson = dto.contactPerson;
        c.email = dto.email;
        c.phone = dto.phone;
        c.address = dto.address;
        c.latitude = dto.latitude;
        c.longitude = dto.longitude;
        c.website = dto.website;
        c.industry = dto.industry;
        c.accountNumber = dto.accountNumber;
        c.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidCustomer(c))
            return CommandResult(false, "", "Invalid customer data");
        repo.save(c);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(CustomerDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing.isNull)
            return CommandResult(false, "", "Customer not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.contactPerson.length > 0) existing.contactPerson = dto.contactPerson;
        if (dto.email.length > 0) existing.email = dto.email;
        if (dto.phone.length > 0) existing.phone = dto.phone;
        if (dto.address.length > 0) existing.address = dto.address;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(CustomerId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Customer not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
