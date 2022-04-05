local defaultVars = import '00-default-vars.libsonnet';
local resApp = import '00-resources-front.libsonnet';
local env = std.extVar("env");
local mult = if (env == "prod") then defaultVars.replicasProdFrontMult else 1;

[{
apiVersion: "apps/v1",
kind: "Deployment",
metadata:{
  name: defaultVars.name+"-front",
  namespace: defaultVars.namespace,
  labels:{
    app: "frontend",
  },
},
spec:{
  replicas: defaultVars.replicasFront * mult,
  selector:{
    matchLabels: {
      app: "frontend",
    },
  },
  template:{
    metadata:{
      labels:{
        app: "frontend",
      },
    },
    spec:{
      containers:[{
        name: "frontend",
        image: defaultVars.imagesFront,
        ports:[{
         containerPort: defaultVars.appPortFront,
          name: "frontend",
        }],
        env:[{
            name: "HTTP_PORT",
            value: std.toString(defaultVars.appPortFront),
        },{
            name: "BACKEND_HOST",
            value: defaultVars.name+"-back",
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
  name: defaultVars.name+"-front",
  namespace: defaultVars.namespace,
},
spec:{
  type: "ClusterIP",
  selector:{
    app: "frontend",
  },
  ports:[{
    name: "frontend",
    port: defaultVars.appPortFront,
    protocol: "TCP",
  }],
},
}]