local env = std.extVar("__ksonnet/environments");
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
                             "name": "WORKFLOW_GENERATOR_MODEL_BUILDER_VERSION",
                             "value": wfparams.modelBuilderVersion
                         },
                         {
                             "name": "WORKFLOW_GENERATOR_MODEL_SERVER_VERSION",
                             "value": wfparams.modelServerVersion
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
            "name": "standard",
        },
        "mountOptions": [
            "dir_mode=0777",
            "file_mode=0777",
            "uid=1000",
            "gid=1000"
        ],
        "parameters": {
            "skuName": "Standard_LRS",
            "storageAccount": "auroraprodstorageaccount"
        },
        "provisioner": "kubernetes.io/azure-file",
        "reclaimPolicy": "Delete"
    },

   // Persistant volume claim - instance of storage class
    {
        "apiVersion": "v1",
        "kind": "PersistentVolumeClaim",
        "metadata": {
            "name": "azurefile",
            "namespace": wfparams.namespace
        },
        "spec": {
            "accessModes": ["ReadWriteMany"],
            "resources": {
                "requests": {
                    "storage": "5Gi"
                },
            },
            "storageClassName": "standard"
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
           "name": "cluster-admin",
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
]
