module uim.platform.authorization.infrastructure.container;

import std.string : toUpper;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct Container {
  AuthorizationRepository repository;
  PolicyEvaluator policyEvaluator;

  ManageApplicationsUseCase manageApplications;
  ManagePoliciesUseCase managePolicies;
  ManageAssignmentsUseCase manageAssignments;
  EvaluateAuthorizationsUseCase evaluateAuthorizations;

  AuthorizationWebModel webModel;
  AuthorizationWebView webView;
  AuthorizationWebController webController;

  AuthorizationCliModel cliModel;
  AuthorizationCliView cliView;
  AuthorizationCliController cliController;

  AuthorizationGuiModel guiModel;
  AuthorizationGuiView guiView;
  AuthorizationGuiController guiController;

  HealthController healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  switch (toUpper(config.storageBackend)) {
    case "FILE":
      c.repository = new FileAuthorizationRepository(config.fileStoragePath);
      break;
    case "MONGODB":
      c.repository = new MongoAuthorizationRepository(config.mongoUri, config.mongoDb, config.mongoCollection);
      break;
    default:
      c.repository = new MemoryAuthorizationRepository();
      break;
  }

  c.policyEvaluator = new PolicyEvaluator();

  c.manageApplications = new ManageApplicationsUseCase(c.repository);
  c.managePolicies = new ManagePoliciesUseCase(c.repository);
  c.manageAssignments = new ManageAssignmentsUseCase(c.repository);
  c.evaluateAuthorizations = new EvaluateAuthorizationsUseCase(c.repository, c.policyEvaluator);

  c.webModel = new AuthorizationWebModel(c.manageApplications, c.managePolicies, c.manageAssignments, c.evaluateAuthorizations);
  c.webView = new AuthorizationWebView();
  c.webController = new AuthorizationWebController(c.webModel, c.webView);

  c.cliModel = new AuthorizationCliModel(c.manageApplications, c.managePolicies, c.manageAssignments, c.evaluateAuthorizations);
  c.cliView = new AuthorizationCliView();
  c.cliController = new AuthorizationCliController(c.cliModel, c.cliView);

  c.guiModel = new AuthorizationGuiModel(c.manageApplications, c.managePolicies, c.manageAssignments, c.evaluateAuthorizations);
  c.guiView = new AuthorizationGuiView();
  c.guiController = new AuthorizationGuiController(c.guiModel, c.guiView);

  c.healthController = new HealthController("authorization");

  return c;
}
