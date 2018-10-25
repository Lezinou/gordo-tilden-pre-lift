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

   // Storage class - azurefile
   {
        "apiVersion": "storage.k8s.io/v1",
        "kind": "StorageClass",
        "metadata": {
            "annotations": {
                "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"storage.k8s.io/v1beta1\",\"kind\":\"StorageClass\",\"metadata\":{\"annotations\":{\"storageclass.beta.kubernetes.io/is-default-class\":\"true\"},\"labels\":{\"kubernetes.io/cluster-service\":\"true\"},\"name\":\"default\",\"namespace\":\"\"},\"parameters\":{\"cachingmode\":\"None\",\"kind\":\"Managed\",\"storageaccounttype\":\"Standard_LRS\"},\"provisioner\":\"kubernetes.io/azure-disk\"}\n",
                "storageclass.beta.kubernetes.io/is-default-class": "true"
            },
            "labels": {
                "kubernetes.io/cluster-service": "true"
            },
            "name": "azurefile",
        },
        "parameters": {
            "cachingmode": "None",
            "kind": "Managed",
            "storageaccounttype": "Standard_LRS"
        },
        "provisioner": "kubernetes.io/azure-file",
        "reclaimPolicy": "Delete"
   },

   // Persistant volume claim - instance of storage class
    {
        "apiVersion": "v1",
        "kind": "PersistentVolumeClaim",
        "metadata": {
            "name": "azurefile-claim"
        },
        "spec": {
            "accessModes": ["ReadWriteMany"],
        },
        "storageClassName": "azurefile",
        "resources": {
            "requests": {
                "storage": "5Gi"
            },
        },
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
               "name": "default",
           },
       ],
       "roleRef": {
           "kind": "ClusterRole",
           "name": "admin",
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
