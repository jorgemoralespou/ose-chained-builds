oc new-project gradle-jdk
oc new-build jorgemoralespou/s2i-java~https://github.com/jorgemoralespou/s2i-java \
             --context-dir=/test/test-app-gradle/ \
             --name=builder

sleep 1

# watch the logs
oc logs -f bc/builder --follow

# Generated artifact is located in /wildfly/standalone/deployments/ROOT.war
oc new-build --name=runtime \
   --docker-image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift \
   --source-image=builder \
   --source-image-path=/opt/openshift/app.jar:. \
   --dockerfile=$'FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift\nCOPY app.jar /deployments/app.jar' \
   --strategy=docker

sleep 1

oc logs -f bc/runtime --follow

# Deploy and expose the app once built
oc new-app runtime --name=my-application
oc expose svc/my-application

# Print the endpoint URL
echo “Access the service at http://$(oc get route/my-application -o jsonpath='{.status.ingress[0].host}')/” 
