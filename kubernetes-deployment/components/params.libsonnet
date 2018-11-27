{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    "workflow-initiator": {
      image: "auroradevacr.azurecr.io/gordo-infrastructure/gordo-deploy:0.1.1",
      name: "ks-workflow-initiator",
      serviceAccountName: "gordo-workflow-runner",
      namespace: "kubeflow",
      roleName: "submit-workflows-role",
      projectName: "gordo-test-project",
      tagFetcherVersion: "0.0.3",
      modelBuilderVersion: "74a916d9-dev",
      modelServerVersion: "74a916d9-dev"
    },
  },
}
