smeagol -- A Read-Only Gollum Server
=============================================

## DESCRIPTION

Smeagol is a server that can run a read-only version of a
[Gollum](http://github.com/github/gollum) wiki. This can be useful when you want
to maintain a standalone copy of a Github wiki but you want to update it through
the Github interface.

Gollum follows the rules of [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.


## INSTALLATION

You can install Smeagol with RubyGems:

	$ [sudo] gem install smeagol

And then, if you want code highlighting, follow the
[Installation Guide](http://pygments.org/docs/installation) for Pygments.

Ta da. You're ready to go.


## RUNNING

To run smeagol, simply change directories to your Gollum repository and run the
`smeagol` executable from the command line:

	$ cd /path/to/repo
	$ smeagol

This will run a web server at `http://localhost:4567`. You can change the port
by setting the `--port` or `-p` option on the command line.


## UPDATING

There are two ways to update the repository through Smeagol:

1. Auto Update
1. Manual Update

To setup Smeagol to automatically update your repository in fixed intervals,
simply pass the `--autoupdate` option in the command line and Smeagol will
automatically perform a `git pull origin master` on your repository once per
day.

To perform a manual update, simply go to the URL,
`http://localhost:4567/update`, and Smeagol will perform a git pull. Change the
URL to your appropriate hostname and port.


## CONTRIBUTE

Have a great idea for Smeagol? Awesome. Fork the repository and add a feature
or fix a bug. There are a couple things I ask:

1. You must have tests for all code you check in.
1. Create an appropriately named topic branch that contains your change.