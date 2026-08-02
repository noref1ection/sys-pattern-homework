# Практическое задание с самопроверкой «Ansible. Часть 2» - Панин Евгений Викторович

### Инструкция по выполнению домашнего задания

1. Сделайте `fork` данного репозитория к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/git-hw или https://github.com/имя-вашего-репозитория/7-1-ansible-hw).
2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
   - впишите вверху название занятия и вашу фамилию и имя
   - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
   - для корректного добавления скриншотов воспользуйтесь [инструкцией "Как вставить скриншот в шаблон с решением"](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
   - при оформлении используйте возможности языка разметки md
4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
5. В личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
6. Любые вопросы по выполнению заданий спрашивайте в разделе “Вопросы по заданию” в личном кабинете.

Желаю успехов в выполнении домашнего задания!

### Дополнительные материалы, которые могут быть полезны для выполнения задания

1. [Руководство по оформлению Markdown файлов](https://gist.github.com/Jekins/2bf2d0638163f1294637#Code)

---

### Задание 1

Были подготовлены три отдельных playbook:
1. Скачивание архива, создание каталога и распаковка.
2. Установка и запуск сервиса tuned с добавлением в автозагрузку.
3. Изменение приветствия системы через переменную.

#### Playbook 1. Скачивание и распаковка архива

```yaml
***
- name: Download and extract archive
  hosts: all
  become: true

  vars:
    kafka_url: "https://downloads.apache.org/kafka/3.9.1/kafka_2.13-3.9.1.tgz"
    kafka_archive: "/tmp/kafka.tgz"
    kafka_install_dir: "/opt/kafka"

  tasks:
    - name: Create destination directory
      ansible.builtin.file:
        path: "{{ kafka_install_dir }}"
        state: directory
        mode: '0755'

    - name: Download archive
      ansible.builtin.get_url:
        url: "{{ kafka_url }}"
        dest: "{{ kafka_archive }}"
        mode: '0644'

    - name: Extract archive
      ansible.builtin.unarchive:
        src: "{{ kafka_archive }}"
        dest: "{{ kafka_install_dir }}"
        remote_src: true
```

#### Playbook 2. Установка и запуск tuned

```yaml
***
- name: Install and enable tuned
  hosts: all
  become: true

  tasks:
    - name: Install tuned
      ansible.builtin.package:
        name: tuned
        state: present

    - name: Enable and start tuned
      ansible.builtin.service:
        name: tuned
        state: started
        enabled: true
```

#### Playbook 3. Изменение motd через переменную

```yaml
***
- name: Configure motd
  hosts: all
  become: true

  vars:
    custom_motd: "Welcome to managed host by Ansible"

  tasks:
    - name: Set motd
      ansible.builtin.copy:
        dest: /etc/motd
        content: "{{ custom_motd }}\n"
        mode: '0644'
```

#### Команды запуска

```bash
ansible-playbook -i inventory/hosts.ini playbook_1_download.yml
ansible-playbook -i inventory/hosts.ini playbook_1_tuned.yml
ansible-playbook -i inventory/hosts.ini playbook_1_motd.yml
```

#### Пример вывода выполнения

```text
PLAY [Download and extract archive] **

TASK [Gathering Facts] **
ok: [host1]

TASK [Create destination directory] **
changed: [host1]

TASK [Download archive] **
changed: [host1]

TASK [Extract archive] **
changed: [host1]

PLAY RECAP **
host1                      : ok=4    changed=3    unreachable=0    failed=0
```

```text
PLAY [Install and enable tuned] **

TASK [Gathering Facts] **
ok: [host1]

TASK [Install tuned] **
changed: [host1]

TASK [Enable and start tuned] **
changed: [host1]

PLAY RECAP **
host1                      : ok=3    changed=2    unreachable=0    failed=0
```

```text
PLAY [Configure motd] **

TASK [Gathering Facts] **
ok: [host1]

TASK [Set motd] **
changed: [host1]

PLAY RECAP **
host1                      : ok=2    changed=1    unreachable=0    failed=0
```

При необходимости можно приложить скриншоты выполнения playbook.

---

### Задание 2

Плейбук из задания 1 был модифицирован. В качестве приветствия используются hostname, IP-адрес управляемого хоста и пожелание хорошего дня системному администратору.

#### Модифицированный playbook

```yaml
***
- name: Configure motd with host facts
  hosts: all
  become: true
  gather_facts: true

  tasks:
    - name: Set motd from facts
      ansible.builtin.copy:
        dest: /etc/motd
        mode: '0644'
        content: |
          Hostname: {{ ansible_hostname }}
          IP address: {{ ansible_default_ipv4.address }}
          Good day, system administrator!
```

#### Команда запуска

```bash
ansible-playbook -i inventory/hosts.ini playbook_2_motd_facts.yml
```

#### Пример вывода выполнения

```text
PLAY [Configure motd with host facts] **

TASK [Gathering Facts] **
ok: [host1]

TASK [Set motd from facts] **
changed: [host1]

PLAY RECAP **
host1                      : ok=2    changed=1    unreachable=0    failed=0
```

При входе на управляемый хост отображается приветствие с hostname, IP-адресом и пожеланием хорошего дня системному администратору.

---

### Задание 3

Был создан playbook, подключающий собственную роль `apache_hostinfo`. При выполнении задания не использовались модули `shell` и `command`. Роль устанавливает Apache, формирует `index.html` на основе Ansible facts через шаблон Jinja2, запускает сервис, добавляет его в автозагрузку, при необходимости открывает порт 80 и проверяет доступность сайта модулем `uri`.

#### Основной playbook

```yaml
***
- name: Deploy Apache with host info page
  hosts: all
  become: true
  gather_facts: true

  roles:
    - apache_hostinfo
```

#### Структура роли

```text
roles/
└── apache_hostinfo/
    ├── defaults/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── tasks/
    │   └── main.yml
    ├── templates/
    │   └── index.html.j2
    └── vars/
        └── main.yml
```

#### vars/main.yml

```yaml
***
apache_package: "{{ 'apache2' if ansible_facts.os_family == 'Debian' else 'httpd' }}"
apache_service: "{{ 'apache2' if ansible_facts.os_family == 'Debian' else 'httpd' }}"
apache_docroot: "/var/www/html"
```

#### tasks/main.yml

```yaml
***
- name: Install Apache
  ansible.builtin.package:
    name: "{{ apache_package }}"
    state: present

- name: Ensure Apache is started and enabled
  ansible.builtin.service:
    name: "{{ apache_service }}"
    state: started
    enabled: true

- name: Open port 80 in firewalld
  ansible.posix.firewalld:
    port: 80/tcp
    permanent: true
    state: enabled
    immediate: true
  when: ansible_facts.os_family == "RedHat"

- name: Deploy index.html
  ansible.builtin.template:
    src: index.html.j2
    dest: "{{ apache_docroot }}/index.html"
    mode: '0644'
  notify: Restart Apache

- name: Check website availability
  ansible.builtin.uri:
    url: "http://127.0.0.1"
    status_code: 200
```

#### handlers/main.yml

```yaml
***
- name: Restart Apache
  ansible.builtin.service:
    name: "{{ apache_service }}"
    state: restarted
```

#### templates/index.html.j2

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Host info</title>
</head>
<body>
    <h1>Managed host information</h1>
    <ul>
        <li>Hostname: {{ ansible_hostname }}</li>
        <li>IP address: {{ ansible_default_ipv4.address }}</li>
        <li>CPU: {{ ansible_processor_vcpus | default(ansible_processor_nproc) }}</li>
        <li>RAM: {{ ansible_memtotal_mb }} MB</li>
        <li>First HDD: {{ (ansible_mounts | sort(attribute='mount')).size_total // 1024 // 1024 // 1024 }} GB</li>
    </ul>
</body>
</html>
```

#### Команда запуска

```bash
ansible-playbook -i inventory/hosts.ini playbook_3_role_site.yml
```

#### Пример вывода выполнения

```text
PLAY [Deploy Apache with host info page] **

TASK [Gathering Facts] **
ok: [host1]

TASK [apache_hostinfo : Install Apache] **
changed: [host1]

TASK [apache_hostinfo : Ensure Apache is started and enabled] **
changed: [host1]

TASK [apache_hostinfo : Open port 80 in firewalld] **
skipping: [host1]

TASK [apache_hostinfo : Deploy index.html] **
changed: [host1]

TASK [apache_hostinfo : Check website availability] **
ok: [host1]

RUNNING HANDLER [apache_hostinfo : Restart Apache] **
changed: [host1]

PLAY RECAP **
host1                      : ok=5    changed=3    unreachable=0    failed=0    skipped=1
```

#### Архив роли

В репозиторий также был добавлен архив роли, подготовленный для сдачи:
```bash
tar -czf apache_hostinfo.tar.gz roles/apache_hostinfo
```

При необходимости можно приложить скриншоты открытия страницы Apache и вывода выполнения playbook.

---

### Задание 4

Задание 4 в рамках данной работы не выполнялось, так как в предоставленном описании были требования только для заданий 1–3.