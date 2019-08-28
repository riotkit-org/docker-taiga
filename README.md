Taiga Dockerized environment
============================

Complete environment to run self-hosted Taiga.io project in an elegant
way.

**Features:**
- Optional SSL support in the container
- Optional events support (allows live updates in the application)
- BUILDS ANY TAIGA VERSION EASILY!
- In comparison to other docker images, this one runs production
  environment...
- Very flexible, a lot of environment variables to configure
- Uses docker-compose to simplify setup, can be used also standalone or
  in Kubernetes/Swarm
- Uses standardized JINJA2 to generate configuration files
- Allows to change a lot of parameters without rebuilding the container
- With Makefile all tasks are automated enough to provide a fully working environment without need to adjust anything

*Notice: This is not a official Taiga.io project and is not affiliated
with Taiga Agile, LLC © or any other company, it's a completly grassroot
project*

*Based on docker image built originally by Benjamin Hutchins <ben@hutchins.co> and released on GPL license*

*Built docker images are licensed under MIT*

#### What is Taiga?

Taiga is a project management platform for startups and agile developers & designers who want a simple, beautiful tool that makes work truly enjoyable.

> [taiga.io](https://taiga.io)

#### Quick start

```
# get the sources
git clone https://github.com/riotkit-org/docker-taiga.git
cd docker-taiga

# configure the environment
cp .env.dist .env
edit .env

# start it!
make start

# tadam...
```

#### Configuring SSL directly in Taiga

There are two ways of configuring SSL, the suggested way is that you set
up a webserver and configure SSL there - you can use Letsencrypt or
other certificate.

Second way is to set up SSL directly in the Taiga container, we will
focus on this.

You need to add your certificates to the container into
`/etc/nginx/ssl/ssl.crt` and `/etc/nginx/ssl/ssl.key` by building a
docker image, using a volume mount or at least `docker cp`.

Then make sure to configure environment variables on Taiga container:

```bash
TAIGA_SCHEME=https
TAIGA_REDIRECT_TO_SSL=true
TAIGA_HOSTNAME=example.riotkit.org
TAIGA_ENABLE_SSL=true
```

#### Configuring LDAP

LDAP support can optionally be enabled by setting the `TAIGA_LDAP` environment variable to `true`. See the Dockerfile for a list of the environment variables used for configuring LDAP and their descriptions.

#### Building images

```
# to build a 4.2.5 version of backend and frontend
make build VERSION=4.2.5

# to build backend v4.2.5 and frontend v4.1.5
make build VERSION=4.2.5 VERSION_FRONT=4.2.4-stable

# will build and tag under some-image:4.2.5
make build VERSION=4.2.5 IMAGE=some-image
```

#### Troubleshooting

If you have trouble logging in or editing user settings it may be related to a failure sending emails. This will be accompanied by a `[CRITICAL] WORKER TIMEOUT` error in the logs. Try validating your email configuration or setting `TAIGA_ENABLE_EMAIL` to `false` to see if that fixes the issue.
