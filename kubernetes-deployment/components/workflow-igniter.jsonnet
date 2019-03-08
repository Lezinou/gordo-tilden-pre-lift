local env = std.extVar("__ksonnet/environments");
local wfparams = std.extVar("__ksonnet/params").components["workflow-initiator"];
[

    /*
        This Deployment is here with the sole purpose of detecting changes in the
        config file. The config file is loaded as an env var to it, so when it changes
        ArgoCD triggers a new apply which triggers the PostSync job which actually submits
        the workflow.

        Additionally, it turns out that it needs to be a 'running' service, not something
        like busybox and echoing the config file for example. Thus we have a dumb looking
        nginx server until a better solution presents itself.

    */
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "name": wfparams.projectName,
            "labels": {
                "app": wfparams.projectName
            }
        },
        "spec": {
            "selector": {
                "matchLabels": {
                    "app": wfparams.projectName
                }
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app": wfparams.projectName
                    }
                },
                "spec": {
                    "containers": [
                        {
                            "image": "nginx:alpine",
                            "name": "nginx",
                            "resources": {
                                "requests": {
                                    "cpu": "25m",
                                    "memory": "10Mi"
                                }
                            },
                            "env": [
                                {
                                    "name": "CONFIG",
                                    "value": importstr "./config/config.yaml"
                                }
                            ]
                        }
                    ]
                }
            },
        }
    },


    {
      "apiVersion": "batch/v1",
      "kind": "Job",
      "metadata": {
         "generateName": wfparams.name,
         "annotations": {
             "argocd.argoproj.io/hook": "PostSync",
             "argocd.argoproj.io/hook-delete-policy": "OnSuccess"
         },

      },
      "spec": {
         "backoffLimit": 2,
         "template": {
            "metadata": {
               "name": wfparams.name,
               "namespace": wfparams.namespace
            },
            "spec": {
               "serviceAccountName": wfparams.serviceAccountName,
               "serviceAccount": wfparams.serviceAccountName,
               "containers": [
                  {
                     "image": wfparams.image,
                     "name": wfparams.name,
                     "env": [
                         {
                             "name": "MACHINE_CONFIG",
                             "value": importstr "./config/config.yaml"
                         },

                         {
                             "name": "ARGO_SUBMIT",
                             "value": "true"
                         },

                         {
                             "name": "WORKFLOW_GENERATOR_PROJECT_NAME",
                             "value": wfparams.projectName
                         },

                         {
                             "name": "WORKFLOW_GENERATOR_TAG_FETCHER_VERSION",
                             "value": wfparams.tagFetcherVersion
                         },

                         {
                             "name": "WORKFLOW_GENERATOR_MODEL_BUILDER_VERSION",
                             "value": wfparams.modelBuilderVersion
                         }
                         /*
                         {
                             "name": "WORKFLOW_GENERATOR_MODEL_SERVER_VERSION",
                             "value": wfparams.modelServerVersion
                         },

                         {
                             "name": "WORKFLOW_GENERATOR_WATCHMAN_VERSION",
                             "value": wfparams.watchmanVersion
                         }
                         */
                     ],
                  }
               ],
               "restartPolicy": "Never"
            }
         }
      }
   }
]
