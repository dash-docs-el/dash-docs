# Dash Docs

[![Build Status](https://api.travis-ci.org/areina/helm-dash.svg?branch=master)](http://travis-ci.org/areina/helm-dash)
[![Coverage Status](https://img.shields.io/coveralls/areina/helm-dash.svg)](https://coveralls.io/r/areina/helm-dash?branch=master)
[![MELPA](http://melpa.org/packages/helm-dash-badge.svg)](http://melpa.org/#/helm-dash)
[![MELPA Stable](http://stable.melpa.org/packages/helm-dash-badge.svg)](http://stable.melpa.org/#/helm-dash)
[![Tag Version](https://img.shields.io/github/tag/areina/helm-dash.svg)](https://github.com/areina/helm-dash/tags)
[![License](http://img.shields.io/:license-gpl3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html)

## What's it

This package provides an elisp interface to query and show documenation using
[Dash](http://www.kapeli.com/dash) docsets.

It doesn't require Dash app.

## Requirements

- sqlite3

## Installation

It's available on [MELPA](https://melpa.org).

Now, it's possible to choose between install the stable or development version
of dash-docs. [Here](https://github.com/milkypostman/melpa#stable-packages)
there is an explanation about stable packages and MELPA and
[here](https://github.com/gilbertw1/dash-docs/tags) a list of our tags.

`m-x package-install dash-docs RET`


## Installing docsets

Dash-docs uses the same docsets as [Dash](http://www.kapeli.com/dash).
You can install them with `m-x dash-docs-install-docset` for the
official docsets or `m-x dash-docs-install-user-docset` for user
contributed docsets (experimental).

To install a docset from a file in your drive you can use `m-x
dash-docs-install-docset-from-file'. That function takes as input
a `tgz` file that you obtained, starting from a folder named `<docset
name>.docset`, with the command:

`tar --exclude='.DS_Store' -cvzf <docset name>.tgz <docset name>.docset`

as explained [here](https://kapeli.com/docsets#dashdocsetfeed).

## Usage

Search all currently enabled docsets (docsets in `dash-docs-docsets` or
`dash-docs-common-docsets`):

    (dash-docs-search "<pattern>")

Search a specific docset:

    (dash-docs-search-docset "<docset>" "<pattern>")

The command `dash-docs-reset-connections` will clear the connections
to all sqlite db's. Use it in case of errors when adding new docsets.
The next call to a search function will recreate them.

## Variables to customize

`dash-docs-docsets-path` is the prefix for your docsets. Defaults to ~/.docsets

`dash-docs-min-length` tells dash-docs from which length to start
searching. Defaults to 3.

`dash-docs-browser-func` is a function to encapsulate the way to browse
Dash' docsets. Defaults to browse-url. For example, if you want to use eww to
browse your docsets, you can do: `(setq dash-docs-browser-func 'eww)`.

When `dash-docs-enable-debugging` is non-nil stderr from sqlite queries is
captured and displayed in a buffer. The default value is `t`. Setting this
to `nil` may speed up queries on some machines (capturing stderr requires
the creation and deletion of a temporary file for each query).


## Sets of Docsets

### Common docsets

`dash-docs-common-docsets' is a list that should contain the docsets
to be active always. In all buffers.

### Buffer local docsets

Different subsets of docsets can be activated depending on the
buffer. For the moment (it may change in the future) we decided it's a
plain local variable you should setup for every different
filetype. This way you can also do fancier things like project-wise
docsets sets.

``` elisp
(defun go-doc ()
  (interactive)
  (setq-local dash-docs-docsets '("Go")))

(add-hook 'go-mode-hook 'go-doc)
```

### Only one docset

To narrow the search to just one docset, type its name in the
beginning of the search followed by a space. If the docset contains
spaces, no problemo, we handle it :D.

### use-package integration

If you are using [use-package](https://github.com/jwiegley/use-package), a :dash
keyboard will be added to configure the `dash-docs-docsets` variable. For
example to register the CMake dash documentation with cmake mode:

``` elisp
(use-package cmake-mode
  :dash "CMake")
```

You can also register multiple docsets:
``` elisp
(use-package cmake-mode
  :dash "CMake" "Foobar")
```

By default, dash-docs will link the docset to the package name mode hook, you
can explicitly set the mode if it is different from the package name:

``` elisp
(use-package my-package
  :dash (my-mode "Docset1" "Docset2"))
```

And you can register to multiple modes:

``` elisp
(use-package my-package
  :dash (my-mode "Docset1" "Docset2")
        (my-other-mode "Docset3"))
```

The way it works is by registering a hook to the given mode (`<mode-name>-hook`)
and setting up `dash-docs-docsets` local variable in that hook.

## FAQ

- Does it work in osX?

sqlite queries. Provisionally, we're executing shell-commands directly. Our
idea is come back to use [esqlite](http://www.github.com/mhayashi1120/Emacs-esqlite)
when some issues will be fixed.

dash-docs has been tested only in linux.  We've been notified that it
doesn't work in Mac, so we ask for elisp hackers who own something
that runs Mac OSX if they could take a look at it.

Hints: It looks like something with 'end of line' differences. The
suspicious are
[esqlite](http://www.github.com/mhayashi1120/Emacs-esqlite) (which
dash-docs requires) or
[pcsv](http://www.github.com/mhayashi1120/Emacs-pcsv) (which esqlite
requires)

- I'm using mac osx and pages open but not in the correct anchor

[bug on **mac osx**'s browse-url](https://github.com/areina/helm-dash/issues/36)
which can't open urls with #. If you find this issue, and want to
debug, great, otherwise, you can use eww or w3 or w3m which will work
just fine

- I get nil for every search I do

make sure you don't have sqlite3 .mode column but .mode list (the default). check your .sqliterc

- When selecting an item in dash-docs, no browser lookup occurs with firefox >= 38.0.and emacs >= 24.4

try:
```
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "/path/to/firefox")
(setq dash-docs-browser-func 'browse-url-generic)
```


## Contribution

We ♥ feedback, issues or pull requests. Feel free to contribute in dash-docs.

We're trying to add tests to the project, if you send a PR please consider add
new or update the existing ones.

Install [Cask](https://github.com/cask/cask) if you haven't already, then:

    $ cd /path/to/dash-docs
    $ cask

Run all tests with:

    $ make


## Authors

- Toni Reina <areina0@gmail.com>
- Raimon Grau <raimonster@gmail.com>
