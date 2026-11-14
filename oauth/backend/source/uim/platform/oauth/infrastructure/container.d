/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.oauth.infrastructure.container;

import uim.platform.oauth;
import uim.platform.oauth.presentation.odata.engine : oauthEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class OAuthContainer {
  OAuthConfig config;
  IDocumentStore store;
  ISecretGenerator secrets;
  ITokenSigner signer;
  SigningKey signingKey;
  OAuthRepositories repositories;
  OAuthPorts ports;
  ODataEngine engine; /// drives OData, REST, CLI and GUI

  /// store / generator may be injected (tests); defaults follow the configuration.
  this(OAuthConfig config, IDocumentStore store = null, ISecretGenerator secrets = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storage, config.dataFile);
    this.secrets = secrets !is null ? secrets : new SystemSecretGenerator;
    signingKey = resolveSigningKey(config, this.store, this.secrets);
    signer = new Hs256TokenSigner(signingKey.secret);

    // driven adapters
    repositories = createRepositories(this.store);

    // application
    auto tokens = new ManageTokensUseCase(repositories);
    auto authentication = new AuthenticateClientsUseCase(repositories.clients);
    ports.tokens = tokens;
    ports.clients = new ManageClientsUseCase(repositories, this.secrets, tokens);
    ports.scopes = new ManageScopesUseCase(repositories);
    ports.brandings = new ManageBrandingsUseCase(repositories);
    ports.authentication = authentication;
    ports.authorization = new AuthorizeUseCase(repositories, this.secrets, config.authorizationCodeValiditySeconds);
    ports.issuer = new IssueTokensUseCase(repositories, authentication, signer, this.secrets, config.issuer);
    ports.introspection = new IntrospectTokensUseCase(repositories, tokens);
    ports.statistics = new OAuthStatisticsService(repositories);

    // one engine for all management adapters
    engine = oauthEngine(ports, config.maxPageSize);
  }
}
