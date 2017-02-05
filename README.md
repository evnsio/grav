# evns/grav

This is a simple Docker image running Grav CMS with the admin panel under Nginx.

For more info on Grav, visit the [Grav Website](https://getgrav.org/).

## Usage

### Docker

The simplest way to run this image with docker alone is:

```
docker run -d -p 80:80 evns/grav
```

This will run grav, and prompt for admin user setup on startup.  Grav will be available on [http://localhost/](http://localhost/)

### Docker-Compose

To simplify further, the container can be started using the supplied [docker-compose.yml](https://github.com/evnsio/grav/blob/master/docker-compose.yml), and running: 

```
docker-compose up -d
```

This will open port 80 for web access, configure the admin user, and create a volume named volume called `userdata` with the grav user data mounted into it. 
All user specific data will mounted on the host in this volume.

## Backing up

To keep your site backed up, simply ensure the `userdata` volume is backed up.

## Restoring/migrating

To restore your site, copy the contents of your backup (or your`/user/` folder) to the `userdata` volume.  