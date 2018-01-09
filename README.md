This is a simple Docker image running Grav CMS with the admin plugin under Nginx.

The container can also optionally generate trusted certs for your domain, using Let's Encrypt.  See [this post](http://evns.io/2017/02/14/ssl-setup.html) for details.

For more info on Grav, visit the [Grav Website](https://getgrav.org/).

## Usage

### Docker

The simplest way to run this image with docker alone is:

```
docker run -d -p 80:80 evns/grav
```

This will run grav, and prompt for admin user setup on startup.  Grav will be available on [http://localhost/](http://localhost/)

### Docker-Compose

To simplify further, the site can be started using the following docker compose: 

```YAML
version: '2'
services:
  site:
    image: evns/grav
    restart: always
    ports:
      - "80:80"
      - "443:443"
    environment:
      - ADMIN_USER=admin
      - ADMIN_PASSWORD=Pa55word
      - ADMIN_EMAIL=admin@example.com
      - ADMIN_PERMISSIONS=b
      - ADMIN_FULLNAME=Admin
      - ADMIN_TITLE=SiteAdmin
      - DOMAIN=example.com    # set to your root/apex domain
      - GENERATE_CERTS=true   # set to true to automatically setup trusted ssl with let's encrypt
    volumes:
      - backup:/var/www/grav-admin/
volumes:
  backup:
    external: false
```

and running:

```
docker-compose up -d
```

This will do the following:
* Open ports 80 and 443 for http(s) access
* Configure the admin user
* Create a volume named `backup` with the grav user data mounted into it
* Generate trusted certificates for 'example.com' using Let's Encrypt
* Configure Nginx with SSL


## Backing up

To create a backup, run the grav backup script in the container:

```
docker exec <container-name> /var/www/grav-admin/bin/grav backup
```

This wil create a new archive in `/var/www/grav-admin/backup` which is also located on the host volume.  
Simply copy this somewhere to ensure you have the full site backed up.  

For example, to synchronise the contents of the volume to s3:
  
```
docker run --volumes-from=<container-name> --rm pmcjury/aws-cli s3 sync /var/www/grav-admin/backup/ s3://<bucket-name>
```

## Restoring/migrating

To restore your site, copy the contents of your backup archive to the backup volume on the host.

The location of the volume on the host can be found with:

```
docker volume inspect <volume-name>
```
