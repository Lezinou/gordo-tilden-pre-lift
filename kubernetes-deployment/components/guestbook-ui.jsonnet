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
         "backoffLimit": 2,
         "template": {
            "metadata": {
               "name": wfparams.name
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
                     ],
                  }
               ],
               "restartPolicy": "Never"
            }
         }
      }
   },

   //  Role
   {
       "apiVersion": "rbac.authorization.k8s.io/v1",
       "kind": "Role",
       "metadata": {
           "namespace": wfparams.namespace,
           "name": wfparams.roleName
       },
       "rules": [
           {
               "apiGroups": ["argoproj.io"],
               "resources": ["workflows"],
               "verbs": ["get", "list", "watch", "create", "update", "patch", "delete"],
           },
       ],
   },


   // ServiceAccount
    {
        "apiVersion": "v1",
        "kind": "ServiceAccount",
        "metadata": {
            "name": wfparams.serviceAccountName,
            "namespace": wfparams.namespace
        },
    },

   // RoleBinding - default view, allow read-only
   {
       "apiVersion": "rbac.authorization.k8s.io/v1",
       "kind": "RoleBinding",
       "metadata": {
           "name": "default-view",
           "namespace": wfparams.namespace
       },
       "subjects": [
           {
               "kind": "ServiceAccount",
               "name": "default:default",
           },
       ],
       "roleRef": {
           "kind": "ClusterRole",
           "name": "view",
           "apiGroup": "rbac.authorization.k8s.io"
       },
   },

   // RoleBinding - allow argo submitting
   {
       "apiVersion": "rbac.authorization.k8s.io/v1",
       "kind": "RoleBinding",
       "metadata": {
           "name": wfparams.roleName,
           "namespace": wfparams.namespace
       },
       "subjects": [
           {
               "kind": "ServiceAccount",
               "name": wfparams.serviceAccountName,
           },
       ],
       "roleRef": {
           "kind": "Role",
           "name": wfparams.roleName,
           "apiGroup": "rbac.authorization.k8s.io"
       },
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
