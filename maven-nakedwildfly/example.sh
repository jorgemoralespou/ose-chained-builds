oc new-project maven-nakedwildfly
oc new-build wildfly~https://github.com/OpenShiftDemos/os-sample-java-web --name=builder

sleep 1

# watch the logs
oc logs -f bc/builder --follow

# Generated artifact is located in /wildfly/standalone/deployments/ROOT.war
oc new-build --name=runtime --docker-image=jboss/wildfly --source-image=builder --source-image-path=/wildfly/standalone/deployments/ROOT.war:. --dockerfile=$'FROM jboss/wildfly\nCOPY ROOT.war /opt/jboss/wildfly/standalone/deployments/ROOT.war' --strategy=docker

sleep 1

oc logs -f bc/runtime --follow

# Deploy and expose the app once built
oc new-app runtime --name=os-sample-java-web
oc expose svc/os-sample-java-web

# Wait for the rollout TODO: There's no liveness and rediness'

# Print the endpoint URL
echo “Access the service at http://$(oc get route/os-sample-java-web -o jsonpath='{.status.ingress[0].host}')/” 
