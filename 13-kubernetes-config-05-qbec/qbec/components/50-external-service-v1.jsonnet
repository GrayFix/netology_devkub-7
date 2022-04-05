local p = import '../params.libsonnet';

[{
kind: "Service",
apiVersion: "v1",
metadata:{
  name: "external-api-v1",
  namespace: p.components.namespace,
  },
spec:{
  type: "ExternalName",
  externalName: "geocode-maps.yandex.ru",
  selector: {},
  ports:[{
    name: "http",
    port: 80,
    protocol: "TCP",
  },{
    name: "https",
    port: 443,
    protocol: "TCP",
  }]
}
}]