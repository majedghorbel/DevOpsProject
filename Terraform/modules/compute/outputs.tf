#Outputting ip
output "public_ip" {
  value       = openstack_compute_instance_v2.Devops_Instance.access_ip_v4
  description = "The public IP address of the web server"
}

#Outputting mac
output "mac_address" {
  value       = openstack_compute_instance_v2.Devops_Instance.network[0].mac
  description = "The mac address of the public interface of the web server"
}