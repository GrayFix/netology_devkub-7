
// this file has the baseline default parameters
{
  components: { // required
  name: "kubernetes-05",
  DB: {
    replicas: 1,
    images: "praqma/network-multitool",
    appPort: 5432,
  },
  Back: {
    replicas: 1,
    images: "praqma/network-multitool",
    appPort: 9000,
    resources: {
      limits:{
        cpu: "200m",
        memory: "256Mi",
      },
      requests:{
        cpu: "100m",
        memory: "128Mi",
      },
    },
  },
  Front: {
    replicas: 1,
    images: "praqma/network-multitool",
    appPort: 8000,
    resources: {
      limits:{
        cpu: "200m",
        memory: "256Mi",
      },
      requests:{
        cpu: "100m",
        memory: "128Mi",
      },
    },
  },
  },
}
