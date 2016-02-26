# Web Developer Exercise

other potential programs/topics:
- configuring/editing `cron` jobs (_seems like Nitrous disables cron by default, hard to get running_)
- managing remote server with `ssh`, `scp`, etc.

## Downloading Files, Unpacking Archives

- `wget` & `tar`

## HTTP Headers

- checking headers e.g. for performance, security reasons
- use `curl --head`
- set up a basic monitoring script to confirm that your website(s) is up, send back the HTTP status code

## RSYNC

syncing files, practice locally

## Network Troubleshooting

- `ping`, `traceroute` (_Nitrous doesn't have this installed_), `ifconfig`

## Explore even more!

Well, if you've made it this far, you're probably pretty good at the command line. There's no a whole lot else we can add, but there are a few interesting tools we can present for you to either learn or spend some time configuring.

Does your library use the **Drupal** CMS? Take a look at setting up Drush: http://www.drush.org/en/master/

Drush is the "Drupal shell" and it allows you to perform common administrative tasks from the command line. You can also set up aliases using a configuration file to run command on external servers. If you're already able to `ssh` into your own servers, give settings up drush a try, and if not take a look at the documentation and see if it'll be useful to you.

There's a similar project for the **Wordpress** CMS, Wordpress-cli: http://wp-cli.org/

Same thing here; try setting this up on your web servers if you have access, or reading through the documentation if you don't.
