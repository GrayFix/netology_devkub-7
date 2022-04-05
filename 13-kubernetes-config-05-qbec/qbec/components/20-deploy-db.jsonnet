local p = import '../params.libsonnet';
local params = p.components.DB;

[{
apiVersion: "apps/v1",
kind: "StatefulSet",
metadata:{
  name: p.components.name+"-db",
},
spec:{
  selector:{
    matchLabels: {
      app: "db",
    },
  },
  serviceName: p.components.name+"-db",
  replicas: params.replicas,
  template:{
    metadata:{
      labels:{
        app: "db",
      },
    },
    spec:{
      terminationGracePeriodSeconds: 10,
      containers:[{
        name: "postgresql",
        image: params.images,
        ports:[{
          containerPort: params.appPort,
          name: "postgresql",
        }],
        env:[{
            name: "HTTP_PORT",
            value: std.toString(params.appPort),
        }],
      }],
    },
  },
},
},{
apiVersion: "v1",
kind: "Service",
metadata:{
  name: p.components.name+"-db",
},
spec:{
  type: "ClusterIP",
  selector:{
    app: "db",
  },
  ports:[{
    name: "postgresql",
    port: params.appPort,
    protocol: "TCP",
  }],
},
}]