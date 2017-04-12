oc new-project go-scratch
oc new-build jorgemoralespou/go-s2i:1.6~https://github.com/jorgemoralespou/ose-chained-builds --context-dir=/go-scratch/hello_world --name=builder

sleep 1

# watch the logs
oc logs -f bc/builder --follow

# Generated artifact is located in /wildfly/standalone/deployments/ROOT.war
oc new-build --name=runtime --docker-image=scratch --source-image=builder --source-image-path=/opt/app-root/src/go/bin/main:. --dockerfile=$'FROM scratch\nCOPY main /main\nEXPOSE 8080\nENTRYPOINT ["/main"]' --strategy=docker

sleep 1

oc logs -f bc/runtime --follow

# Deploy and expose the app once built
oc new-app runtime --name=hello-world-go
oc expose svc/hello-world-go

# Wait for the rollout TODO: There's no liveness and rediness'

# Print the endpoint URL
echo “Access the service at http://$(oc get route/hello-world-go -o jsonpath='{.status.ingress[0].host}')/” 
