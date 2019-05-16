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

Please create a Github issue for discussion before making a pull request.

## Local Development

Local development requires this theme to be used in an `mkdocs` (either new or existing) site.
The `requirements.txt` (in the `mkdocs` site) needs to be updated to reference the local copy.

```
#git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal
git+file:///Users/pivotal/workspace/mkdocs-pivotal-theme#egg=mkdocs-pivotal
```

Make your changes to the local copy. *AND `git commit` them*.
In your `mkdocs` site, run `pip3 uninstall -y mkdocs-pivotal && pip3 install -U -requirements`.
Then `mkdocs serve` your site to see your changes.

If there is an easier workflow, please create a Github issue to explain, please.