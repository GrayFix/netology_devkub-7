local defaultVars = import '00-default-vars.libsonnet';
local resApp = import '00-resources-back.libsonnet';
local env = std.extVar("env");
local mult = if (env == "prod") then defaultVars.replicasProdBackMult else 1;

[{
apiVersion: "apps/v1",
kind: "Deployment",
metadata:{
  name: defaultVars.name+"-back",
  namespace: defaultVars.namespace,
  labels:{
    app: "backend",
  },
},
spec:{
  replicas: defaultVars.replicasBack * mult,
  selector:{
    matchLabels: {
      app: "backend",
    },
  },
  template:{
    metadata:{
      labels:{
        app: "backend",
      },
    },
    spec:{
      containers:[{
        name: "backend",
        image: defaultVars.imagesBack,
        ports:[{
         containerPort: defaultVars.appPortBack,
          name: "backend",
        }],
        env:[{
            name: "HTTP_PORT",
            value: std.toString(defaultVars.appPortBack),
        },{
            name: "DB_HOST",
            value: defaultVars.name+"-db",
        }],
        resources: resApp,
      },
      ],
    },
  },
},
},{
apiVersion: "v1",
kind: "Service",
metadata:{
  name: defaultVars.name+"-back",
  namespace: defaultVars.namespace,
},
spec:{
  type: "ClusterIP",
  selector:{
    app: "backend",
  },
  ports:[{
    name: "backend",
    port: defaultVars.appPortBack,
    protocol: "TCP",
  }],
},
}]