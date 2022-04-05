local namespace = import '10-namespace.jsonnet';
local deployDB = import '20-deploy-db.jsonnet';
local deployBack = import '30-deploy-back.jsonnet';
local deployFront = import '40-deploy-front.jsonnet';
local externalService = import '50-external-service-v1.jsonnet';

namespace +
deployDB +
deployBack +
deployFront +
externalService


