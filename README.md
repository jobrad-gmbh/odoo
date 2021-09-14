# Odoo

[![Build Status](https://runbot.odoo.com/runbot/badge/flat/1/master.svg)](https://runbot.odoo.com/runbot)
[![Documentation](https://img.shields.io/badge/master-docs-875A7B.svg?style=flat&colorA=8F8F8F)](https://www.odoo.com/documentation/17.0)
[![Help](https://img.shields.io/badge/master-help-875A7B.svg?style=flat&colorA=8F8F8F)](https://www.odoo.com/forum/help-1)
[![Nightly Builds](https://img.shields.io/badge/master-nightly-875A7B.svg?style=flat&colorA=8F8F8F)](https://nightly.odoo.com/)

Odoo is a suite of web based open source business apps.

The main Odoo Apps include an [Open Source CRM](https://www.odoo.com/page/crm),
[Website Builder](https://www.odoo.com/app/website),
[eCommerce](https://www.odoo.com/app/ecommerce),
[Warehouse Management](https://www.odoo.com/app/inventory),
[Project Management](https://www.odoo.com/app/project),
[Billing &amp; Accounting](https://www.odoo.com/app/accounting),
[Point of Sale](https://www.odoo.com/app/point-of-sale-shop),
[Human Resources](https://www.odoo.com/app/employees),
[Marketing](https://www.odoo.com/app/social-marketing),
[Manufacturing](https://www.odoo.com/app/manufacturing),
[...](https://www.odoo.com/)

Odoo Apps can be used as stand-alone applications, but they also integrate seamlessly so you get
a full-featured [Open Source ERP](https://www.odoo.com) when you install several Apps.

## Getting started with Odoo

For a standard installation please follow the [Setup instructions](https://www.odoo.com/documentation/17.0/administration/install/install.html)
from the documentation.

To learn the software, we recommend the [Odoo eLearning](https://www.odoo.com/slides),
or [Scale-up, the business game](https://www.odoo.com/page/scale-up-business-game).
Developers can start with [the developer tutorials](https://www.odoo.com/documentation/17.0/developer/howtos.html).

## Security

If you believe you have found a security issue, check our [Responsible Disclosure page](https://www.odoo.com/security-report)
for details and get in touch with us via email.

# ⚠️ Updating Python dependencies

Be aware that when working with `pyproject.toml` file you also have to update `pyproject.toml` in our
[odoo-addons-jobrad](https://github.com/jobrad-gmbh/odoo-addons-jobrad) repository.

[`jobrad-gmbh/odoo-addons-jobrad/pyproject.toml`](https://github.com/jobrad-gmbh/odoo-addons-jobrad/blob/develop/pyproject.toml)
is a **superset** of
[`jobrad-gmbh/odoo/pyproject.toml`](https://github.com/jobrad-gmbh/odoo/blob/jobrad-16.0/pyproject.toml) which means
that the group `[tool.poetry.group.odoo.dependencies]` is present in both of the files. This is a consequence of us
versioning projects and their sets of dependencies instead of Python packages. Since we are "gluing" repositories
together, their `pyproject.toml` files have to be in sync.

The process of updating
[`jobrad-gmbh/odoo-addons-jobrad/pyproject.toml`](https://github.com/jobrad-gmbh/odoo-addons-jobrad/blob/develop/pyproject.toml)
has been automated through
[`scripts/python_environment/sync-odoo-deps-in-pyproject-toml.py`](https://github.com/jobrad-gmbh/odoo-addons-jobrad/blob/develop/scripts/python_environment/sync-odoo-deps-in-pyproject-toml.py).
In order to run the script, you need to have Python and Poetry installed. The script updates
`[tool.poetry.group.odoo.dependencies]` group and runs `poetry lock` for you. If you want to see how the new
`pyproject.toml` will look like without actually updating it, you can specify `--dry-run` flag.

For more information, read [this](https://github.com/jobrad-gmbh/odoo-addons-jobrad/blob/develop/docs/development.md).
