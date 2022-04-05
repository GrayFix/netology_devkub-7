
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
  namespace: "netology-prod",
  Back +: {
    replicas: 2,
    resources +: {
      limits +:{
        memory: "512Mi",
      },
      requests +:{
        memory: "256Mi",
      },
    },
  },
  Front +: {
    replicas: 3,
    resources +: {
      limits +:{
        memory: "512Mi",
      },
      requests +:{
        memory: "256Mi",
      },
    },
  },
  }
}
