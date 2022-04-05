{
  name: "kubernetes-04",
  namespace: "netology",

  replicasDB: 1,
  imagesDB: "praqma/network-multitool",
  appPortDB: 5432,

  replicasBack: 1,
  replicasProdBackMult: 2,
  imagesBack: "praqma/network-multitool",
  appPortBack: 9000,

  replicasFront: 1,
  replicasProdFrontMult: 3,
  imagesFront: "praqma/network-multitool",
  appPortFront: 8000,

}
