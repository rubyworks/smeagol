Smeagol - A Read-Only Gollum Server
===================================

[Website](http://rubyworks.github.com/smeagol) /
[Documentation](http://rubydoc.info/rubyworks/smeagol)
[Source Code](http://github.com/rubyworks/smeagol) /
[Report Issue](http://github.com/rubyworks/smeagol/issues)


## DESCRIPTION

Smeagol is a server that can run a read-only version of a
[Gollum](http://github.com/github/gollum) wiki. This can be useful when you want
to maintain a standalone copy of a Github wiki but you want to update it through
the Github interface.

Smeagol follows the rules of [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.


## INSTALLATION

You can install Smeagol with RubyGems:

    $ [sudo] gem install smeagol

And then, if you want code highlighting, follow the
[Installation Guide](http://pygments.org/docs/installation) for Pygments.

Ta da! You're ready to go.

Of course, the first thing you need to do is clone your Gollum wiki repo.

    $ git clone git@github.com:user/user.github.com.git


## VIEWING

To view your site via smeagol, simply change directories to your Gollum repository
and run `smeagol preview` from the command line:

    $ cd /path/to/repo
    $ smeagol preview

This will run a web server at `http://localhost:4567`. You can change the port
by setting the `--port` or `-p` option on the command line.


## CUSTOMIZING

Of course, you want to customize your site to suit your style. To do this you
need to setup your wiki repo with some Smeagol support files. You can use the
`init` command to have Smeagol put the default files in place.

    $ cd path/to/wiki
    $ smeagol init

In your wiki this will add a few files. One of these is `settings.yml` which you
use to configure smeagol for your site. See SETTINGS below.

There will also be a file called `_Layout.html`. Using Mustache templating
use this file to create a custom page layout for your site. To learn more
about the varaibles available for use in this template see
the [Smeagol Wiki](http://github.com/rubyworks/smeagol/wiki).

Be sure to add these files to your repo and commit them. (You can just check
these files in and push to the server. It will not effect you Gollum
wiki in any way.)


## SETTINGS

The `settings.yml` file allows you to confgure certain behaviors of Smeagol.
An example `settings.yml` file:

    ---
    static: public
    url: http://trans.github.com
    source_url: http://github.com/trans
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

Probably the most important feild is `static`. By setting this to `public`, we inform
Smeagol that we deploying a static site and the static files are to be saved in 'public/`
directory.

See the API documentation for more details about each field.


## BUILDING

To generate a static site use the the `build` command.

    $ cd /path/to/wiki
    $ smeagol build

By default the build will be placed in `public/` in the wiki repo. To use an
alternate destination use the `-d`/`--dir` options.

    $ smeagol build -d /path/to/site

The default location can be changed in `settings.yml` via the `static` field.


## UPDATING

Updating only works when using the Smeagol server. It does not work for static
sites. There are two ways to update the repository through Smeagol:

* Auto Update
* Manual Update

To setup Smeagol to automatically update your repository in fixed intervals,
simply pass the `--auto-update` option in the command line and Smeagol will
automatically perform a `git pull origin master` on your repository once per day.

To perform a manual update, simply go to the `update` route, e.g. `http://localhost:4567/update`,
and Smeagol will perform a git pull. Change the URL for your appropriate hostname and port.


## CONTRIBUTE

Have a great idea for Smeagol? Awesome. Fork the repository and add a feature
or fix a bug. There are a couple things I ask:

* Create an appropriately named topic branch that contains your change.
* Please try to provide tests for all code you check in.

Note that Smeagol uses QED, Citron and AE for testing.


## COPYRIGHTS

Smeagol is distributed under the terms of the **BSD-2-Clause** license.

* Copyright 2012 Trans, Rubyworks
* Copyright 2009 Ben Johnson

Please see LICENSE.txt file for details.

