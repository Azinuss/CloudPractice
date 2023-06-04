# Создание ключевой пары для доступа к ВМ
module "keypair" {
  source             = "./modules/keypair"
  keypair_name       = "keypair-tf"
  keypair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9dnZV5CSpI+ynaiGmqUE6ej4PtNjsByP0emnlKCBQ+0jU3FWU7R1loTbyrOEjjPe4//KygpUCx5HZTDfy4zJzg1Ukb3bbsT1AW/FcQPiwacWBkBH9nmyfLEJETfwZDeBSTrUem1LdMMLDmn6T0nmGnOoI1R0iEHr5qKeKEpQtcPIyG1uVYrvnr8a+BW0EfoYKOfmr7f5th1r/iRT3UXlBid9H3tWT7ORupgligRhTkLX58oa2J+vfoqvTWJbymYZIZppUeLdktbRWwePKkgCMfaNV/XI1oV3j/06xJ1x64zHW0KKKhT9aVG/FKgr6bnN2LemyY+f4mdgkV88GeU/vCuuQXlF3ZXkxPqlwc/6E4tJOI9d9PoDl0XF3G/35drX+XrfqWLzk6NWnwlB067ectRPB4TOZ4vNy+h2GcgWlv+YEii7GJ7HhLQovHXA7DVZRoluRf8wSYJdTFoWgWL4TeaTyChhGimt5IgvZu7f5MMvw3b5I3Wo2rKJ5YDUaips= Алексей@DESKTOP-1I1I8P8"
  region             = var.region
}

# Создание приватной сети для ВМ
module "nat" {
  source = "./modules/nat"
}

# Создание прерываемого сервера.
module "preemptible_server" {
  count  = 2
  source = "./modules/server_remote_root_disk"

  server_name         = var.server_name
  server_zone         = var.server_zone
  server_vcpus        = var.server_vcpus
  server_ram_mb       = var.server_ram_mb
  server_root_disk_gb = var.server_root_disk_gb
  server_volume_type  = var.server_volume_type
  server_image_name   = var.server_image_name
  server_ssh_key      = module.keypair.keypair_name
  region              = var.region
  network_id          = module.nat.network_id
  subnet_id           = module.nat.subnet_id

  # Для смены прерываемого сервера на обычный используйте
  # переменную server_no_preemptible_tag:
  # server_preemptible_tag = var.server_no_preemptible_tag
  server_preemptible_tag = var.server_preemptible_tag
  #  server_ssh_key_user    = ""
}

# Создание inventory файла для ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("./resources/inventory.tmpl",
    {
      webapp_vm_ip_public  = module.preemptible_server.0.floating_ip,
      database_vm_ip_public      = module.preemptible_server.1.floating_ip,
      webapp_vm_ip_nat     = module.preemptible_server.1.nat_ip.0
    }
  )
  filename = "../ansible/inventory.ini"
}