import json
from setuptools import setup, find_packages

# Load list of dependencies
with open("requirements.txt") as data:
    install_requires = [
        line for line in data.read().split("\n")
            if line and not line.startswith("#")
    ]

# Package description
setup(
    name = "mkdocs-pivotal",
    version = "1.1.2",
    license = "MIT",
    author = "JT Archie, Jesse Alford",
    author_email = "jarchie@pivotal.io, jalford@pivotal.io",
    packages = find_packages(),
    include_package_data = True,
    install_requires = install_requires,
    entry_points = {
        "mkdocs.themes": [
            "pivotal = pivotal",
        ]
    },
    zip_safe = False
)
