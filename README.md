# Getting Started

1. Start a new mkdocs site

   ```bash
   mkdocs new my-docs
   cd my-docs
   ```

2. Add the theme to the `requirements.txt`

   ```
   git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal
   mkdocs-material
   ```

3. Set the theme in the `mkdocs.yml`

   ```yaml
   theme: pivotal
   ```

4. Enjoy with `mkdocs serve`.
