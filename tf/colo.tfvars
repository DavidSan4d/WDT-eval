name = "wlvm-colo"
type = "test"
locations = ["las"]
instances = 3
size = "2x4"
cname_pattern = ["wlvm-colo-{num2}"]
lb_route_prefixes = ["wlvm-colo-lb"]
swap = 4
