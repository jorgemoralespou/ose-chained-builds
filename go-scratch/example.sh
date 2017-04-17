oc new-project go-scratch
oc import-image jorgemoralespou/s2i-go --confirm
oc new-build s2i-go~https://github.com/jorgemoralespou/ose-chained-builds \
   --context-dir=/go-scratch/hello_world \
   --name=builder

sleep 1

# watch the logs
oc logs -f bc/builder --follow

# Generated artifact is located in /opt/app-root/src/go/src/main/main
oc new-build --name=runtime \
   --docker-image=scratch \
   --source-image=builder \
   --source-image-path=/opt/app-root/src/go/src/main/main:. \
   --dockerfile=$'FROM scratch\nCOPY main /main\nEXPOSE 8080\nENTRYPOINT ["/main"]' \
   --strategy=docker

sleep 1

oc logs -f bc/runtime --follow

# Deploy and expose the app once built
oc new-app runtime --name=my-application
oc expose svc/my-application

# Print the endpoint URL
echo “Access the service at http://$(oc get route/my-application -o jsonpath='{.status.ingress[0].host}')/” 
