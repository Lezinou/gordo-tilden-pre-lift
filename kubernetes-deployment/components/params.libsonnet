{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    "workflow-initiator": {
      image: "auroradevacr.azurecr.io/gordo-infrastructure/gordo-deploy:0.10.0",
      name: "ks-workflow-initiator",
      serviceAccountName: "gordo-workflow-runner",
      namespace: "kubeflow",
      roleName: "submit-workflows-role",
      projectName: "lezin",
      tagFetcherVersion: "0.3.0"
      /*
      modelBuilderVersion: "4385aba8",
      modelServerVersion: "4385aba8",
      watchmanVersion: "4385aba8"
      */
    },
  },
}
