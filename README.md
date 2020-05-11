# Introduction

This is the Pivotal (now VMware) theme for `mkdocs`.
It allows the docs branding to be pulled in
without having any HTML/CSS/JS in your content repo.

This uses the `mkdocs-material` theme as a base theme.
The design has been optimized for information architecture,
navigation, and viewing across devices.

# Getting Started

We've made some changes to the theme to work with MkDocs v5.0+.

The changes reflected below:
* lock the version mkdocs to range
* redefining the `markdown_extensions` to the newer configuration,
  for example, `pymdownx.highlight` is now handling `linenums`.
* Allow transition to `pymdownx.tabbed` for tabs;
  the superfences tabs sytnax still works for now,
  but is deprecated.
  We recommend transitioning tabbed content to the new format
  as soon as is convenient.

1. Start a new mkdocs site

   ```bash
   mkdocs new my-docs
   cd my-docs
   git init
   git add -A
   git ci -m 'my new docs site'
   ```

1. Add the theme to the `requirements.txt`.

   For development/staging branches,
   we recommend floating with the latest version:

   ```
   git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal
   ```
   
   For version-specific/production branches,
   we recommend pinning to an exact version:
   
   ```
   git+https://github.com/pivotal/mkdocs-pivotal-theme@v1.0.0#egg=mkdocs-pivotal
   ```
   
   We strongly recommend avoiding declaring/specifying either
   the dependencies from this theme's `requirements.txt`
   or additional Python dependencies,
   to the extent possible.
   This allows the theme to be responsible for managing
   version inter-dependencies.

1. Set the theme in the `mkdocs.yml`

   ```yaml
   theme: pivotal
   markdown_extensions:
   - admonition
   - pymdownx.extra
   - pymdownx.highlight:
       linenums: true
   - pymdownx.snippets:
       check_paths: true
   - pymdownx.superfences
   - pymdownx.tabbed
   - sane_lists
   ```

1. Commit the changes.

   ```bash
   git add requirements.txt
   git ci -m 'add the pivotal theme'
   ```

1. Enjoy locally with `mkdocs serve`.

# Versioning

This repo is semantically versioned.
The versioned API consists of
the supported python markdown extensions
for the configuration `mkdocs.yml` configuration listed above,
and the install/build procedure.

Any change that requires a change to the docs themselves,
the build script,
or the configuration in `mkdocs.yml` would be considered breaking.
This does not necessarily extend to
pymdownx extensions we don't indicate above,
or other Python packages we don't install in `requirements.txt`.

# Contribution

Please create a Github issue for discussion 
before making a pull request.

## Local Development

Local development requires this theme 
to be used in an `mkdocs` (either new or existing) site.
`requirements.txt` (in the `mkdocs` site) needs to be updated
to reference the local copy.

First, make sure that `mkdocs-pivotal-theme` is uninstalled,
by running `pip3 uninstall -r requirements.txt` to uninstall everything.

Now that you're working from a clean state,
comment out `git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal` 
in the `requirements.txt` of your docs repo (not the `mkdocs-pivotal-theme`).

Add `~/workspace/mkdocs-pivotal-theme`
(or the path to where this repo is checked out)
to the `requirements.txt` of your docs repo.
Then `pip3 install -r requirements.txt`.

Then, run `pip3 install --editable ~/workspace/mkdocs-pivotal-theme`
to install a local, editable copy.
Any changes to the theme will be automatically rendered in your `mkdocs` server,
without having to restart the server or reinstall any packages.

After completing development in `mkdocs-pivotal-theme`
after all changes are pushed,
uncomment `git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal`
and run `pip3 install --force-reinstall -r requirements.txt` in your docs repo.


