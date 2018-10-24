## Gordo Base Project

---

This project forms the foundation for interacting with the Gordo ML Platform.

Namely there is a single [`config.yaml`](/private/milg/Projects/gordo-test-project/kubernetes-deployment/components/config/config.yaml)
 file which you will be interested in.

.  
+-- [README.md](README.md)  
+-- kubernetes-deployment  
|   +-- components  
|       +-- config/  
|           +-- config.yaml

---

### **Do not modify anything else within the `kubernetes-deployment` directory!**

## Example config:

```yaml
machines:
 Machine-1:
   tags:
     - GRA-GT  -23-0607.PV
     - GRA-TE  -23-0734D.PV
     - GRA-TE  -23-0737B.PV
     - GRA-TIT -23-0615.PV

 Machine-2:
   tags:
     - GRA-TE  -23-0737B.PV
     - GRA-TT  -23-0725.PV
     - GRA-TE  -23-0737D.PV

 Machine-3:
   tags:
     - GRA-GT  -23-0607.PV
     - GRA-TE  -23-0734SEL.PV
     - GRA-YE  -23-0753X.PV
     - GRA-TE  -23-0737B.PV
     - GRA-TE  -23-0737C.PV
     - GRA-TE  -23-0737D.PV
```

You _must_ specify `machines` keyword and then an arbitrary number of required
machines, where each machine has a unique name, followed by `tags` key and a list of required strings.

## Deployments:

Simply make your changes to the `config.yaml` file and commit to `master` branch of the repository. The Gordo ML Platform will take care of the rest. 