# Задание 3
## Terraform
Для начала создадим два файла( terraform.tfvars и backend.tfvars) с переменными которые будут хранить чувствительные данные, но они будут добавлены в .gitignore.
Далее инициализируем terraform командой:
```bash
terraform init --backend-config=backend.tfvars
```
В результате получем сообщение: ![img.png](assets/terraform_init.png)
После при помощи команды создадим и применим план изменений:
```bash
terraform apply
```
Как результат получим команду подключения по ssh для двух серверов и количество примененных изменений.
![img.png](assets/terraform_apply.png)
Проверим выполенение команды дополнительно при помощи онлайн сервиса.
Как видно, сервера онлайн:
![img.png](assets/servers_online.png)
Так же настроена локальная сеть:
![img.png](assets/network.png)
## Ansible
Для работы с ansible был запущен отдельный контейнер с linux системой.
![img.png](assets/Dockerfile.png)
После запуска серверов при помощи terraform запустим приложения на них приложения при помощи ansible: 
![img.png](assets/ansible_work.png)
![img.png](assets/ansible_end.png)
## Заключение
В результате всех манипуляций был запущен сайт с небольшим функционалом:
![img.png](assets/app_online.png)
После окончания всех работ вся структура была удалена:
![img.png](assets/terraform_destroy.png)