local p = import '../params.libsonnet';
local params = p.components.Back;

[{
apiVersion: "apps/v1",
kind: "Deployment",
metadata:{
  name: p.components.name+"-back",
  namespace: p.components.namespace,
  labels:{
    app: "backend",
  },
},
spec:{
  replicas: params.replicas,
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
        image: params.images,
        ports:[{
         containerPort: params.appPort,
          name: "backend",
        }],
        env:[{
            name: "HTTP_PORT",
            value: std.toString(params.appPort),
        },{
            name: "DB_HOST",
            value: p.components.name+"-db",
        }],
        resources: params.resources,
      },
      ],
    },
  },
},
},{
apiVersion: "v1",
kind: "Service",
metadata:{
  name: p.components.name+"-back",
  namespace: p.components.namespace,
},
spec:{
  type: "ClusterIP",
  selector:{
    app: "backend",
  },
  ports:[{
    name: "backend",
    port: params.appPort,
    protocol: "TCP",
  }],
},
}]