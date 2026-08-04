package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/volcengine/volcengine-go-sdk/service/vpc"
	"github.com/volcengine/volcengine-go-sdk/volcengine"
	"github.com/volcengine/volcengine-go-sdk/volcengine/session"
)

func main() {
	var (
		action    = flag.String("action", "", "VPC API action for the IPv4 Gateway lifecycle or its default route")
		gatewayID = flag.String("gateway-id", "", "IPv4 Gateway ID")
		name      = flag.String("name", "", "IPv4 Gateway name for create")
		region    = flag.String("region", os.Getenv("VOLCENGINE_REGION"), "Volcengine region")
		routeID   = flag.String("route-entry-id", "", "Route entry ID for delete-route")
		tableID   = flag.String("route-table-id", "", "Route table ID for create-route")
		vpcID     = flag.String("vpc-id", "", "VPC ID for attach")
	)
	flag.Parse()

	if *region == "" {
		fatalf("region is required through -region or VOLCENGINE_REGION")
	}

	apiAction, params := requestFor(*action, *gatewayID, *name, *vpcID, *tableID, *routeID)
	config := volcengine.NewConfig().WithRegion(*region)
	sess, err := session.NewSession(config)
	if err != nil {
		fatalf("create SDK session: %v", err)
	}

	client := vpc.New(sess)
	req, output := client.CreateVpcCommonRequest(&params)
	req.Operation.Name = apiAction
	if err := req.Send(); err != nil {
		fatalf("call %s: %v", apiAction, err)
	}

	encoded, err := json.MarshalIndent(output, "", "  ")
	if err != nil {
		fatalf("encode response: %v", err)
	}
	fmt.Println(string(encoded))
}

func requestFor(action, gatewayID, name, vpcID, tableID, routeID string) (string, map[string]interface{}) {
	switch action {
	case "create":
		if name == "" {
			fatalf("-name is required for create")
		}
		return "CreateIpv4Gateway", map[string]interface{}{
			"Ipv4GatewayName": name,
		}
	case "describe":
		params := map[string]interface{}{
			"PageNumber": 1,
			"PageSize":   100,
		}
		if gatewayID != "" {
			params["Ipv4GatewayIds.1"] = gatewayID
		}
		return "DescribeIpv4Gateways", params
	case "attach":
		requireGatewayID(gatewayID)
		if vpcID == "" {
			fatalf("-vpc-id is required for attach")
		}
		return "AttachIpv4Gateway", map[string]interface{}{
			"Ipv4GatewayId": gatewayID,
			"VpcId":         vpcID,
		}
	case "enable":
		requireGatewayID(gatewayID)
		return "EnableIpv4Gateway", map[string]interface{}{
			"Ipv4GatewayId": gatewayID,
		}
	case "create-route":
		requireGatewayID(gatewayID)
		if tableID == "" {
			fatalf("-route-table-id is required for create-route")
		}
		return "CreateRouteEntry", map[string]interface{}{
			"RouteTableId":         tableID,
			"DestinationCidrBlock": "0.0.0.0/0",
			"NextHopType":          "Ipv4GW",
			"NextHopId":            gatewayID,
			"RouteEntryName":       name,
		}
	case "delete-route":
		if routeID == "" {
			fatalf("-route-entry-id is required for delete-route")
		}
		return "DeleteRouteEntry", map[string]interface{}{
			"RouteEntryId": routeID,
		}
	case "disable":
		requireGatewayID(gatewayID)
		return "DisableIpv4Gateway", map[string]interface{}{
			"Ipv4GatewayId": gatewayID,
		}
	case "detach":
		requireGatewayID(gatewayID)
		if vpcID == "" {
			fatalf("-vpc-id is required for detach")
		}
		return "DetachIpv4Gateway", map[string]interface{}{
			"Ipv4GatewayId": gatewayID,
			"VpcId":         vpcID,
		}
	case "delete":
		requireGatewayID(gatewayID)
		return "DeleteIpv4Gateway", map[string]interface{}{
			"Ipv4GatewayId": gatewayID,
		}
	default:
		fatalf("unsupported -action %q", action)
		return "", nil
	}
}

func requireGatewayID(gatewayID string) {
	if gatewayID == "" {
		fatalf("-gateway-id is required for this action")
	}
}

func fatalf(format string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, format+"\n", args...)
	os.Exit(1)
}
