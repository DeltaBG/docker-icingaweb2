# [<img alt="Delta Cloud" width="256" height="66" src="https://static.delta.bg/external-images/svg/delta_logo_wide.svg" />][website]

Since 2009 Delta Cloud has been providing tailored IT services based on the actual needs of their corporate customers. For every project the team examines thoroughly the client's business needs and designs a delivery process optimized for easy maintenance, low expenditures and future scaling.

The value proposition of the company is the young, but experienced team of network engineers, DevOps engineers, and system administrators, who design, create, and maintain the solutions for delivery. These solutions include Application and Content Acceleration, Automation, Backup and Recovery, Cloud Infrastructure, Cloud Networking, Cloud Storage, Collaboration, Colocation Services, Consulting Services, Content Delivery (CDN), Data Migration, Data Networks, DevOps, Disaster Recovery, Disaster Recovery and Business Continuity, eCommerce, Hybrid Cloud Computing, Hybrid IT, Infrastructure as a Service, Integration Services, Managed Security, Managed Services, Managed Storage, Monitoring, Networking, Network Optimization, Platform as a Service (PaaS), Private Cloud, Private Hosting, Professional Services, Workload Orchestration.

# About Icinga Web 2

Icinga Web 2 is a powerful web interface for the Icinga 2 system monitoring tool based on PHP. It’s fast, responsive, accessible and easily extensible with modules.

More about Icinga Web 2 can be found [here](https://icinga.com/docs/icinga-web-2/latest/doc/01-About/). 

# 🚀 Production-ready Icinga Web 2 by Delta Cloud

This is an Icinga Web 2 docker image, built by the Delta Cloud team, designed to handle small and large updates seamlessly. 

## Image details

- Based on [ubuntu:focal](https://hub.docker.com/_/ubuntu)
- Ready to use Icinga Web 2
- Key-Features:
  - icingaweb2
  - icingacli
  - icingaweb2-graphite module
  - icingaweb2-director module
  - icingaweb2-incubator module
  - SSL support
- No SSH. Use docker [exec](https://docs.docker.com/engine/reference/commandline/exec/).

## Requirements

This docker container cannot operate as standalone. It needs the following containers:

- [mariadb:focal](https://hub.docker.com/_/mariadb)
- [deltabg/icinga2](https://hub.docker.com/r/deltabg/icinga2)
- [graphiteapp/graphite-statsd](https://hub.docker.com/r/graphiteapp/graphite-statsd) (Optional)

## Usage

We made three deployment examples. You can use them according to your needs. 

### Manual deployment

You can find the sample environment file `example.env` in our [GitHub project][github]. It can be customized to your liking.

##### Clone the project

```bash
git clone https://github.com/DeltaBG/docker-icingaweb2.git
cd docker-icingaweb2
```

##### Configure the environment

Open `example.env` with your favorite text editor and customize it to your needs.

```bash
vi example.env
```

##### Create icinga network

```bash
docker network create icinga
```

##### Run MariaDB container

```bash
docker run -d \
  --network icinga \
  --name icinga_mariadb \
  --restart unless-stopped \
  --env-file ./example.env \
  -h icinga-mariadb \
  -v /data/var/lib/mysql:/var/lib/mysql \
  --health-cmd "mysqladmin ping -h localhost -p$MYSQL_ROOT_PASSWORD" \
  --health-interval 30s \
  --health-timeout 30s \
  --health-retries 3 \
  --health-start-period 5s \
  mariadb:focal
```

##### Run Icinga 2 container

```bash
docker run -d \
  --privileged \
  --network icinga \
  --name icinga_icinga2 \
  --restart unless-stopped \
  --env-file ./example.env \
  -h icinga-icinga2 \
  -p 5665:5665 \
  -v /data/etc/icinga2:/etc/icinga2 \
  -v /data/var/lib/icinga2:/var/lib/icinga2 \
  -v /data/var/log/icinga2:/var/log/icinga2 \
  deltabg/icinga2
```

##### Run Icinga Web 2 container

```bash
docker run -d \
  --network icinga \
  --name icinga_icingaweb2 \
  --restart unless-stopped \
  --env-file ./example.env \
  -h icinga-icingaweb2 \
  -p 80:80 \
  -p 443:443 \
  -v /data/etc/icingaweb2:/etc/icingaweb2 \
  -v /data/var/log/icingaweb2:/var/log/icingaweb2 \
  -v /data/var/log/apache2:/var/log/apache2 \
  deltabg/icingaweb2
```

### Docker Compose deployment

You can find the sample file `docker-compose.yml` in our [GitHub project][github].

##### Clone the project

```bash
git clone https://github.com/DeltaBG/docker-icingaweb2.git
cd docker-icingaweb2
```

##### Configure the environment

Open `example.env` with your favorite text editor and customize it to your needs.

```bash
vi example.env
```

##### Perform the deployment

```bash
docker-compose up -d
```

### Ansible Playbook deployment

You can find the sample file `ansible-playbook.yml` in our [GitHub project][github].

##### Clone the project

```bash
git clone https://github.com/DeltaBG/docker-icingaweb2.git
cd docker-icingaweb2
```

##### Configure the environment

Open `example.env` with your favorite text editor and customize it to your needs.

```bash
vi example.env
```

##### Perform the deployment

```bash
ansible-playbook ansible-playbook.yml
```

## Additional information

### SSL Support

SSL support can be enabled by setting the `ICINGAWEB2_SSL` variable to `true`.

You can enable the automatic issuance of a Let's Encrypt certificate based on Apache 2 mod_md. Set the `ICINGAWEB2_SSL_LETSENCRYPT` variable to `true` and populate the variables `ICINGAWEB2_APACHE_SERVER_NAME` and `ICINGAWEB2_APACHE_SERVER_ADMIN` with a valid hostname and email address.

If you'd like, you can also use your own commercial certificate. You need to add a volume to `/etc/apache2/ssl` that contains these files:

- `cert.pem` - Certificate file
- `privkey.pem` - Private key file
- `chain.pem` - Certificate chain file

### Director module

The Icinga Director module is installed and disabled by default. You can enable it by setting the `ICINGAWEB2_MODULE_DIRECTOR` variable to `true`. The automatic kickstart is enabled when Director module is enabled. You can disable kickstart by setting the `ICINGAWEB2_MODULE_DIRECTOR_KICKSTART` variable to `false`.

By default the Director module uses the same MariaDB container as that of Icinga Web 2. If you want to use another database, check the variables with prefix `ICINGAWEB2_MODULE_DIRECTOR_MYSQL_*`.

### Graphite module

The Graphite module can be activated by setting the `ICINGAWEB2_MODULE_GRAPHITE` variable to `true`. This container does not have graphite and carbon daemons, so you need to use an external container, such as [graphiteapp/graphite-statsd](https://hub.docker.com/r/graphiteapp/graphite-statsd), and set a value to the variable `ICINGAWEB2_MODULE_GRAPHITE_HOST`.

Launch the graphite container before the others. You can use the following example:

```bash
docker run -d \
  --network icinga \
  --name icinga_graphite \
  --restart unless-stopped \
  --env-file ./example.env \
  -h icinga-graphite \
  graphiteapp/graphite-statsd
```

## Reference

### Environment variables

Variables marked in **bold** are recommended to be adjusted according to your needs.

| Variable                                        | Default Value        | Description                                            |
| ----------------------------------------------- | -------------------- | ------------------------------------------------------ |
| `DEFAULT_MYSQL_PORT`                            | 3306                 | Default database port.                                 |
| `MYSQL_ROOT_USER`                               | root                 | Database root user.                                    |
| **`MYSQL_ROOT_PASSWORD`**                       |                      | Database root user password.                           |
| `ICINGAWEB2_MYSQL_HOST`                         | icinga-mariadb       | Hostname or IP address for the Icinga 2 database.      |
| `ICINGAWEB2_MYSQL_PORT`                         | `DEFAULT_MYSQL_PORT` | Port for the Icinga 2 database.                        |
| `ICINGAWEB2_MYSQL_DB`                           | icingaweb2           | Database name for the Icinga 2 database.               |
| `ICINGAWEB2_MYSQL_USER`                         | icingaweb2           | Username for the Icinga 2 database.                    |
| **`ICINGAWEB2_MYSQL_PASSWORD`**                 | 2bewagnici           | Password for the Icinga 2 database.                    |
| `ICINGA2_MYSQL_HOST`                            | icinga-mariadb       | Hostname or IP address of the Icinga 2 database.       |
| `ICINGA2_MYSQL_PORT`                            | `DEFAULT_MYSQL_PORT` | Port of the Icinga 2 database.                         |
| `ICINGA2_MYSQL_DB`                              | icinga2              | Database name of the Icinga 2 database.                |
| `ICINGA2_MYSQL_USER`                            | icinga2              | Username of the Icinga 2 database.                     |
| **`ICINGA2_MYSQL_PASSWORD`**                    | 2agnici              | Password of the Icinga 2 database.                     |
| `ICINGA2_API_HOST`                              | icinga-icinga2       | Hostname or IP address of the Icinga 2 API.            |
| `ICINGA2_API_PORT`                              | 5665                 | Port of the Icinga 2 API.                              |
| `ICINGA2_API_USER`                              | icingaweb2           | Username of the Icinga 2 API.                          |
| **`ICINGA2_API_PASSWORD`**                      | 2bewagnici           | Password of the Icinga 2 API.                          |
| **`ICINGAWEB2_ADMIN_USER`**                     | icingaadmin          | Icinga Web 2 login user.                               |
| **`ICINGAWEB2_ADMIN_PASSWORD`**                 | icinga               | Icinga Web 2 login password.                           |
| `ICINGAWEB2_SSL`                                | false                | Enable or disable SSL/HTTPS support.                   |
| `ICINGAWEB2_SSL_LETSENCRYPT`                    | false                | Enable or disable automated Let's Encrypt certificate. |
| **`ICINGAWEB2_APACHE_SERVER_NAME`**             | example.com          | Valid hostname for Apache 2.                           |
| **`ICINGAWEB2_APACHE_SERVER_ADMIN`**            | admin@example.com    | Valid e-mail for Apache 2.                             |
| `ICINGAWEB2_MODULE_DIRECTOR`                    | false                | Enable or disable Director module.                     |
| `ICINGAWEB2_MODULE_DIRECTOR_KICKSTART`          | true                 | Enable or disable Director kickstart.                  |
| `ICINGAWEB2_MODULE_DIRECTOR_MYSQL_HOST`         | icinga-mariadb       | Hostname or IP address for the Director database.      |
| `ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PORT`         | `DEFAULT_MYSQL_PORT` | Port for the Director database.                        |
| `ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB`           | icingaweb2_director  | Database name for the Director database.               |
| `ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER`         | icingaweb2_director  | Username for the Director database.                    |
| **`ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PASSWORD`** | rotcerid_2bewagnici  | Password for the Director database.                    |
| `ICINGAWEB2_MODULE_GRAPHITE`                    | false                | Enable or disable Graphite module.                     |
| `ICINGAWEB2_MODULE_GRAPHITE_HOST`               | icinga-graphite      | Hostname or IP address of the Carbon/Graphite.         |

### Volumes

The following folders are configured and can be mounted as volumes.

| Volume              | Description                                |
| ------------------- | ------------------------------------------ |
| /etc/icingaweb2     | Icinga Web 2 configuration folder.         |
| /etc/apache2/ssl    | SSL-Certificates folder (see SSL Support). |
| /var/log/icingaweb2 | Icinga Web 2 log folder.                   |
| /var/log/apache2    | Apache 2 log folder.                       |

# Authors

- [Nedelin Petkov](https://github.com/mlg1)
- [Valentin Dzhorov](https://github.com/vdzhorov/)

# License

Licensed under the terms of the [MIT license](/LICENSE).

# Follow us!

If you like what we do in this and our other projects, follow us!

[<img alt="Delta Cloud | Facebook" width="32px" src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/facebook.svg"/>][facebook] 
[<img alt="Delta Cloud | Twitter" width="32px" src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/twitter.svg"/>][twitter]
[<img alt="Delta Cloud | LinkedIn" width="32px" src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/linkedin.svg"/>][linkedin]

[website]: https://delta.bg/?utm_source=github&utm_medium=logo&utm_campaign=git_camp
[github]: https://github.com/DeltaBG/docker-icingaweb2
[facebook]: https://www.facebook.com/Delta.BG
[twitter]: https://twitter.com/deltavps
[linkedin]: https://www.linkedin.com/company/delta-bg/
