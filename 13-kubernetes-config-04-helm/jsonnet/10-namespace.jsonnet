local defaultVars = import '00-default-vars.libsonnet';
[{
apiVersion: "v1",
kind: "Namespace",
metadata:{
  name: defaultVars.namespace,
}
}]