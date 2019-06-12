# Introduction

These are utility concourse scripts and tasks.
It is on purpose that there is no _pipeline as a product_. Ask @jtarchie for philosical reasons.

* `Dockerfile` contains the tools needed to run these tasks, scripts, and `mkdocs`. *UNRELEASED*
* `build-docs` script will build a versioned docs site based on the inputs that are passed into it.
  You must build your own task as there is no way to dynmacially define inputs on a task.

  <details>
  <summary>For example, in your define the branches (versions) of your docs, and mount them as inputs into your task.</summary>

  ```yaml
  resources:
  - name: mkdocs-pivotal-theme
    type: git
    source: { uri: https://github.com/pivotal/mkdocs-pivotal-theme }
  - name: docs-v1.1
    type: git
    source:
      uri: https://github.com/org/my-docs
      branch: v1.1
  - name: docs-v1.2
    type: git
    source:
      uri: https://github.com/org/my-docs
      branch: v1.2
  - name: docs-app
    type: cf
    source:
      api: api.run.pivotal.io
      username: ((cf-username))
      password: ((cf-password))
      organization: some-docs
      space: some-docs

  jobs:
  - name: build-docs
    serial: true
    plan:
      - get: mkdocs-pivotal-theme
      - get: docs-v1.1
      - get: docs-v1.2
      - task: build-docs
        config:
          image_resource:
            type: docker-image
            source: { repository: internalpcfplatformautomation/docs }
          inputs:
          - name: docs-v1.1
          - name: docs-v1.2
          - name: mkdocs-pivotal-theme
          outputs:
          - name: cf-app
          run:
            path: mkdocs-pivotal-theme/ci/build-docs/build-docs
            args: [
              '--output-dir', './cf-app',
              '--docs-dir', '.',
              '--docs-prefix', 'docs',
              '--site-prefix', 'my-project-name',
              '--domains', 'docs.pivotal.io'
              ]
      - put: docs-app
        params:
          manifest: cf-app/manifest.yml
          path: cf-app
          current_app_name: ((cf-app-name))
          show_app_log: true
  ```
  </details>
