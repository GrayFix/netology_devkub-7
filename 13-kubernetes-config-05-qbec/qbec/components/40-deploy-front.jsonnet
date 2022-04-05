local p = import '../params.libsonnet';
local params = p.components.Front;

[{
apiVersion: "apps/v1",
kind: "Deployment",
metadata:{
  name: p.components.name+"-front",
  namespace: p.components.namespace,
  labels:{
    app: "frontend",
  },
},
spec:{
  replicas: params.replicas,
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
        image: params.images,
        ports:[{
         containerPort: params.appPort,
          name: "frontend",
        }],
        env:[{
            name: "HTTP_PORT",
            value: std.toString(params.appPort),
        },{
            name: "BACKEND_HOST",
            value: p.components.name+"-back",
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
  name: p.components.name+"-front",
  namespace: p.components.namespace,
},
spec:{
  type: "ClusterIP",
  selector:{
    app: "frontend",
  },
  ports:[{
    name: "frontend",
    port: params.appPort,
    protocol: "TCP",
  }],
},
}]