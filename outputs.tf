output "web_servers" {
  value = {
    for vm in yandex_compute_instance.web : vm.name => {
      internal_ip = vm.network_interface[0].ip_address
      external_ip = vm.network_interface[0].nat_ip_address
    }
  }
}

output "load_balancer_ip" {
  value = one(one(yandex_lb_network_load_balancer.web.listener).external_address_spec).address
}
