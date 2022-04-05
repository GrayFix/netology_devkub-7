local defaultVars = import '00-default-vars.libsonnet';

[{
apiVersion: "apps/v1",
kind: "StatefulSet",
metadata:{
  name: defaultVars.name+"-db",
  namespace: defaultVars.namespace,
},
spec:{
  selector:{
    matchLabels: {
      app: "db",
    },
  },
  serviceName: defaultVars.name+"-db",
  replicas: defaultVars.replicasDB,
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
        image: defaultVars.imagesDB,
        ports:[{
          containerPort: defaultVars.appPortDB,
          name: "postgresql",
        }],
        env:[{
            name: "HTTP_PORT",
            value: std.toString(defaultVars.appPortDB),
        }],
      }],
    },
  },
},
},{
apiVersion: "v1",
kind: "Service",
metadata:{
  name: defaultVars.name+"-db",
  namespace: defaultVars.namespace,
},
spec:{
  type: "ClusterIP",
  selector:{
    app: "db",
  },
  ports:[{
    name: "postgresql",
    port: defaultVars.appPortDB,
    protocol: "TCP",
  }],
},
}]