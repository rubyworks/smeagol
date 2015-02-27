Smeagol - A Read-Only Gollum Server
===================================

[Website](http://rubyworks.github.com/smeagol) |
[Documentation](http://rubydoc.info/rubyworks/smeagol) |
[Source Code](http://github.com/rubyworks/smeagol) |
[Report Issue](http://github.com/rubyworks/smeagol/issues)


**Smeagol is up for adoption if anyone finds it useful and would like to take over
it's development. Please get in touch either via email or posting an issue.**

Smeagol is a server that can run a read-only version of a
[Gollum](http://github.com/github/gollum) wiki. This can be useful when you
want to maintain a standalone website, but you want to update it through
the Gollum wiki interface, e.g. via GitHub.

Smeagol also includes a static site generator that can convert
a Gollum wiki into a static website to be served by any hosting
service. 

Smeagol follows the rules of [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.


## STATUS

[![Build Status](https://secure.travis-ci.org/rubyworks/smeagol.png)](http://travis-ci.org/rubyworks/smeagol)

Currently Smeagol's core functionaily works, but it needs some love to clean up
some rough spots.


## INSTALLATION

You can install Smeagol with RubyGems:

    $ [sudo] gem install smeagol

And then, if you want code highlighting, follow the
[Installation Guide](http://pygments.org/docs/installation) for Pygments.

Ta da! You're ready to go.

Of course, the first thing you need to do is clone your Gollum wiki repo.

    $ git clone git@github.com:user/user.github.com.git


## USAGE

### Previewing

To preview your site via smeagol, simply change directories to your Gollum repository
and run `smeagol preview` from the command line:

    $ cd /path/to/repo
    $ smeagol preview

This will run a web server at `http://localhost:4567`. You can change the port
by setting the `--port` or `-p` option on the command line.

### Customizing

Of course, you want to customize your site to suit your style. To do this you
need to add some Smeagol support files. Use the `init` command to have Smeagol
put the default files in place.

    $ cd path/to/wiki
    $ smeagol init

In your wiki this will add a few files. One of these is `_config.yml` which you
use to configure Smeagol for your site. See CONFIGURATION below.

There will also be a file called `_layouts/page.mustache`. Using Mustache templating
use this file to create a custom page layout for your site. To learn more
about the variables available for use in this template see
the [Smeagol Wiki](http://github.com/rubyworks/smeagol/wiki).

Be sure to add these files to your repo and commit them. (You can just check
these files in and push to the server. It will not effect you Gollum
wiki in any way.)

### Configuration

If you are familiar with Jekyll, the static site generator, you will notice 
that Smeagol follows the same convensions fairly closely. This has been done
to reduce congnative load for those of us who use both tools, and to simplify
transition to a static site should that ever needed.

The `_config.yml` file allows you to configure certain behaviors of Smeagol.
An example `_config.yml` file:

    ---
    port: 4000
    host: 127.0.0.1
    baseurl: "" # does not include hostname
    sourceurl: http://github.com/trans

    title: 7R4N5.C0D3
    author: trans
    description:
      Trans Programming Blog

    menu:
    - title: Homepage
      href: "/"
    - title: RSS Feed
      href: "/rss.xml"
    - title: Projects
      href: "http://github.com/trans"

See the API documentation for more details about each field.

**NOTE** The `menu` entry will be probably be deprecated in favor of just
editing templates.

### Serving

Smeagol can serve multiple Gollum repos simulataneously. To do this
create a configuration file at `~/.smeagol/config.yml`. An example file
looks like this:

    ---
    port: 3000
    auto_update: true
    cache_enabled: true
    repositories:
      - path: ~/websites/acme/wiki
        cname: acme.org
        origin: 'git@github.com:acme/acme.wiki.git'
        ref: master
        bare: false
        secret: X123

Then to serve the listed repositories use:

    $ smeagol serve

### Updating

There are two ways to handle updates of the repository through Smeagol: 
*automatic updating* and *manual updating*.

To setup Smeagol to automatically update your repository in fixed intervals,
simply pass the `--auto-update` option in the `smeagol-serve` command and Smeagol
will automatically perform a `git pull origin master` on your repository once
per day.

To perform a manual update, simply go to the `update` route, e.g. `http://localhost:4567/update`,
and Smeagol will perform a git pull. Of course, change the URL appropriately
for your hostname and port.


## ROADMAP

The most recent versions of Smeagol had focused on adding static site generation
to the project. This goal has now been dropped. Static site generation, it turns 
out, is not an important goal for Smeagol becuase that can accomplished using
other tools, particularly Jekyll, with only a modicum of extra work. In that
light, we are currently updating Smeagol's configuration defaults to be as
similar to Jekyll's as possible. This will facilitate the transition to static
should that ever be required and more generally reduce the cognative load on
developers.


## CONTRIBUTING

Have a great idea for Smeagol? Awesome. Fork the repository and add a feature
or fix a bug. There are a couple things we ask:

* Create an appropriately named topic branch that contains your change.
* Please try to provide tests for all code you check in.
* Use an apprpriate commit tag, such as `:doc:`, `:test:`, etc.

Note that Smeagol uses Citron and AE for testing. And admittedly this project
is waterfalling too much at present. So if you would like to contribute, but
don't have any specific request, writing a few tests would be a great help.


## COPYRIGHTS

Smeagol is distributed under the terms of the **BSD-2-Clause** license.

* Copyright 2012 Rubyworks
* Copyright 2009 Ben Johnson

Please see LICENSE.txt file for details.

