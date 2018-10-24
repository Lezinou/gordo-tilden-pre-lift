local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["guestbook-ui"];
local wfparams = std.extVar("__ksonnet/params").components["workflow-initiator"];
[
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
         "template": {
            "metadata": {
               "name": wfparams.name
            },
            "spec": {
               "containers": [
                  {
                     "image": wfparams.image,
                     "name": wfparams.name,
                     "command": wfparams.command,
                     "env": [
                         {
                             "name": "MACHINE_CONFIG",
                             "value": importstr "./config/config.yaml"
                         },
                         {
                             "name": "ARGO_SUBMIT",
                             "value": true
                         },
                     ],
                  }
               ],
               "restartPolicy": "Never"
            }
         }
      }
   },
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "name": params.name
      },
      "spec": {
         "ports": [
            {
               "port": params.servicePort,
               "targetPort": params.containerPort
            }
         ],
         "selector": {
            "app": params.name
         },
         "type": params.type
      }
   },
   {
      "apiVersion": "apps/v1beta2",
      "kind": "Deployment",
      "metadata": {
         "name": params.name
      },
      "spec": {
         "replicas": params.replicas,
         "selector": {
            "matchLabels": {
               "app": params.name
            },
         },
         "template": {
            "metadata": {
               "labels": {
                  "app": params.name
               }
            },
            "spec": {
               "containers": [
                  {
                     "image": params.image,
                     "name": params.name,
                     "env": [
                         {
                             "name": "CONFIG",
                             "value": importstr "./config/config.yaml"
                         },
                     ],
                     "ports": [
                     {
                        "containerPort": params.containerPort
                     }
                     ]
                  }
               ]
            }
         }
      }
   }
]
