local defaultVars = import '00-default-vars.libsonnet';
local env = std.extVar("env");
if (env == "prod") then [
{
kind: "Service",
apiVersion: "v1",
metadata:{
  name: "external-api-v1",
  namespace: defaultVars.namespace,
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
},
}] else []