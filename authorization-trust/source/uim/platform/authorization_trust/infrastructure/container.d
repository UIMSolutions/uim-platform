/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.container;

import uim.platform.authorization_trust.infrastructure.config;

// Repositories
import uim.platform.authorization_trust.infrastructure.persistence.memory.oauth_clients;
import uim.platform.authorization_trust.infrastructure.persistence.memory.scopes;
import uim.platform.authorization_trust.infrastructure.persistence.memory.roles;
import uim.platform.authorization_trust.infrastructure.persistence.memory.role_collections;
import uim.platform.authorization_trust.infrastructure.persistence.memory.user_assignments;
import uim.platform.authorization_trust.infrastructure.persistence.memory.identity_providers;

// Domain services
import uim.platform.authorization_trust.domain.services.token_service;

// Use cases
import uim.platform.authorization_trust.application.usecases.manage.oauth_clients;
import uim.platform.authorization_trust.application.usecases.manage.scopes;
import uim.platform.authorization_trust.application.usecases.manage.roles;
import uim.platform.authorization_trust.application.usecases.manage.role_collections;
import uim.platform.authorization_trust.application.usecases.manage.user_assignments;
import uim.platform.authorization_trust.application.usecases.manage.identity_providers;

// Controllers
import uim.platform.authorization_trust.presentation.http.controllers.oauth_client;
import uim.platform.authorization_trust.presentation.http.controllers.scope_controller;
import uim.platform.authorization_trust.presentation.http.controllers.role;
import uim.platform.authorization_trust.presentation.http.controllers.role_collection;
import uim.platform.authorization_trust.presentation.http.controllers.user_assignment;
import uim.platform.authorization_trust.presentation.http.controllers.identity_provider;
import uim.platform.authorization_trust.presentation.http.controllers.token;
import uim.platform.service.presentation.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemoryOAuthClientRepository      oauthClientRepo;
  MemoryScopeRepository            scopeRepo;
  MemoryRoleRepository             roleRepo;
  MemoryRoleCollectionRepository   roleCollectionRepo;
  MemoryUserAssignmentRepository   userAssignmentRepo;
  MemoryIdentityProviderRepository identityProviderRepo;

  // Domain services
  TokenService tokenService;

  // Use cases (application layer)
  ManageOAuthClientsUseCase      manageOAuthClients;
  ManageScopesUseCase            manageScopes;
  ManageRolesUseCase             manageRoles;
  ManageRoleCollectionsUseCase   manageRoleCollections;
  ManageUserAssignmentsUseCase   manageUserAssignments;
  ManageIdentityProvidersUseCase manageIdentityProviders;

  // Controllers (driving adapters)
  OAuthClientController      oauthClientController;
  ScopeController            scopeController;
  RoleController             roleController;
  RoleCollectionController   roleCollectionController;
  UserAssignmentController   userAssignmentController;
  IdentityProviderController identityProviderController;
  TokenController            tokenController;
  HealthController           healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure — repositories
  c.oauthClientRepo      = new MemoryOAuthClientRepository();
  c.scopeRepo            = new MemoryScopeRepository();
  c.roleRepo             = new MemoryRoleRepository();
  c.roleCollectionRepo   = new MemoryRoleCollectionRepository();
  c.userAssignmentRepo   = new MemoryUserAssignmentRepository();
  c.identityProviderRepo = new MemoryIdentityProviderRepository();

  // Domain services
  c.tokenService = new TokenService(c.oauthClientRepo);

  // Application use cases
  c.manageOAuthClients      = new ManageOAuthClientsUseCase(c.oauthClientRepo);
  c.manageScopes            = new ManageScopesUseCase(c.scopeRepo);
  c.manageRoles             = new ManageRolesUseCase(c.roleRepo);
  c.manageRoleCollections   = new ManageRoleCollectionsUseCase(c.roleCollectionRepo);
  c.manageUserAssignments   = new ManageUserAssignmentsUseCase(c.userAssignmentRepo, c.roleCollectionRepo);
  c.manageIdentityProviders = new ManageIdentityProvidersUseCase(c.identityProviderRepo);

  // Presentation controllers
  c.oauthClientController      = new OAuthClientController(c.manageOAuthClients);
  c.scopeController            = new ScopeController(c.manageScopes);
  c.roleController             = new RoleController(c.manageRoles);
  c.roleCollectionController   = new RoleCollectionController(c.manageRoleCollections);
  c.userAssignmentController   = new UserAssignmentController(c.manageUserAssignments);
  c.identityProviderController = new IdentityProviderController(c.manageIdentityProviders);
  c.tokenController            = new TokenController(c.tokenService);
  c.healthController           = new HealthController("authorization-trust");

  return c;
}
