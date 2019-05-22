# Introduction

This is the Pivotal theme for `mkdocs`.
It allows the docs branding to be pulled in without having any HTML/CSS/JS in your content repo.

This uses the `mkdocs-material` theme as a base theme.
The design has been optimized for information architecture, navigation, and viewing across devices.

The intention is as updates are pushed all content repos get them following the build commands.
These build commands can be used for a local preview or on the web.

# Getting Started

1. Start a new mkdocs site

   ```bash
   mkdocs new my-docs
   cd my-docs
   git init
   git add -A
   git ci -m 'my new docs site'
   ```

1. Add the theme to the `requirements.txt`

   ```
   git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal
   mkdocs-material
   ```

1. Set the theme in the `mkdocs.yml`

   ```yaml
   theme: pivotal
   ```

1. Commit the changes.

   ```bash
   git add requirements.txt
   git ci -m 'add the pivotal theme'
   ```

1. Enjoy locally with `mkdocs serve`.

# Contribution

Please create a Github issue for discussion 
before making a pull request.

## Local Development

Local development requires this theme 
to be used in an `mkdocs` (either new or existing) site.
`requirements.txt` (in the `mkdocs` site) needs to be updated to reference the local copy.

First, make sure that `mkdocs-pivotal-theme` is uninstalled,
by running `pip uninstall -r requirements.txt` to uninstall everything.

Now that you're working from a clean state,
comment out `git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal` 
in the `requirements.txt` of your docs repo (not the `mkdocs-pivotal-theme`).

Then, run `pip install --editable /path/to/mkdocs-pivotal-theme/`
to install a local, editable copy.
Any changes to the theme will be automatically rendered in your `mkdocs` server,
without having to restart the server or reinstall any packages.

After completing development into `mkdocs-pivotal-theme`
after all changes are pushed,
uncomment `git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal`
and run `pip install --force-reinstall -r requirements.txt`

# Link Linting

Checking the validity of your links can be done using CI, 
or directly from the command line.

To use, please provide:

   - a source repo,
   - a url where your docs site is running,
   - an optional whitelist to exclude certain links from causing errors.
   
Example: `./ci/linter/link-linter.sh path-to-local-docs-repo http://127.0.0.1:8000 https://google.com`

**NOTE**: Links defined by single brackets are not checked by this tool.
      Please use either `[title][link]` or `[title](link)` to guarantee the linter will check it.

