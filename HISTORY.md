# RELEASE HISTORY

## v0.6.0 / 2012-07-01

Version 0.6 is a major refactoring of the code base.
While all the prevsious functionaility remains, new
features have been added some configuration settings
have been adjusted. Users of previous version should
consult update documentation and adjust their sites
accordingly.

* Use _layouts directory to store templates.
* Use _settings.yml instead of settings.yml.
* Add commands for handling static builds.
* Add init command for setting up a new wiki.

## v0.5.9

Bug fix release for static site generation.

* Static site generator bug fixes. (kylef)

## v0.5.8

This release adds ability to generate a static site.

* Added static site generator. (kylef)

## v0.5.7

Simple CSS style fix release. 

* Fix frame in CSS.

## v0.5.3

* Upgrade to Gollum 1.1.1

## v0.5.2

New release adds Google Analytics support. Just
add a `tracking_id` to setting.yml.

* Added Google Analytics support

## v0.5.1

Release fixes bug in menu generation.

* Fixed menu bug.

## v0.5.0

This release adds support for site versions. The old
versions of pages can be viewed by providing the commit
id or tag name in the URL.

* Added versioning using git tags.

## v0.4.2

This release imvproves CSS styling, including the addtion
of a CSS reset.

* Added CSS styles.
* Added CSS reset.

## v0.4.1

Bug release fixes missing require issue.

* Missing require bug fixed.

## v0.4.0

This release adds a number of new features, such as
GitHub "fork me" ribbon support. It also makes a few 
API adjustments.

* Added secret update key.
* Added GitHub ribbon support.
* Added footer to home page.
* Changed `is_not_home?` to `not_home?` on Mustache page view.
* Renamed `--autoupdate` CLI option to `--auto-update`.
* Moved update functionality into Smeagol::Wiki.
* CSS Fixes: code & H3

## v0.3.0

First public release of Smeagol!

* Added multiple repository support.
* Added `smeagold` process daemon.
* Removed Bundler dependency.
* Added HTML5 shiv for IE support.

