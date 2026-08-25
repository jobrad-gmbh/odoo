# Part of Odoo. See LICENSE file for full copyright and licensing details.

import os.path
import tempfile
from os.path import join as opj
from unittest.mock import patch

import odoo.addons
from odoo.modules import module
from odoo.modules.module import load_manifest
from odoo.modules.module import get_manifest
from odoo.release import major_version
from odoo.tests.common import BaseCase


class TestModuleManifest(BaseCase):
    @classmethod
    def setUpClass(cls):
        cls._tmp_dir = tempfile.TemporaryDirectory(prefix='odoo-test-addons-')
        cls.addClassCleanup(cls._tmp_dir.cleanup)
        cls.addons_path = cls._tmp_dir.name

        patcher = patch.object(odoo.addons, '__path__', [cls.addons_path])
        cls.startClassPatcher(patcher)

    def setUp(self):
        self.module_root = tempfile.mkdtemp(prefix='odoo-test-module-', dir=self.addons_path)
        self.module_name = os.path.basename(self.module_root)

    def test_default_manifest(self):
        with open(opj(self.module_root, '__manifest__.py'), 'w') as file:
            file.write(str({'name': f'Temp {self.module_name}', 'license': 'MIT'}))

        with self.assertNoLogs('odoo.modules.module', 'WARNING'):
            manifest = load_manifest(self.module_name)

        self.maxDiff = None
        self.assertDictEqual(manifest, {
            'addons_path': self.addons_path,
            'application': False,
            'assets': {},
            'author': 'Odoo S.A.',
            'auto_install': False,
            'bootstrap': False,
            'category': 'Uncategorized',
            'data': [],
            'demo': [],
            'demo_xml': [],
            'depends': [],
            'description': '',
            'external_dependencies': [],
            'icon': '/base/static/description/icon.png',
            'init_xml': [],
            'installable': True,
            'images': [],
            'images_preview_theme': {},
            'license': 'MIT',
            'live_test_url': '',
            'name': f'Temp {self.module_name}',
            'post_init_hook': '',
            'post_load': '',
            'pre_init_hook': '',
            'sequence': 100,
            'snippet_lists': {},
            'summary': '',
            'test': [],
            'update_xml': [],
            'uninstall_hook': '',
            'version': f'{major_version}.1.0',
            'web': False,
            'website': '',
        })

    def test_change_manifest(self):
        module_name = 'base'
        new_manifest = get_manifest(module_name)
        orig_auto_install = new_manifest['auto_install']
        new_manifest['auto_install'] = not orig_auto_install
        self.assertNotEqual(new_manifest, get_manifest(module_name))
        self.assertEqual(orig_auto_install, get_manifest(module_name)['auto_install'])

    def test_missing_manifest(self):
        with self.assertLogs('odoo.modules.module', 'DEBUG') as capture:
            manifest = load_manifest(self.module_name)
        self.assertEqual(manifest, {})
        self.assertIn("no manifest file found", capture.output[0])

    def test_missing_license(self):
        with open(opj(self.module_root, '__manifest__.py'), 'w') as file:
            file.write(str({'name': f'Temp {self.module_name}'}))
        with self.assertLogs('odoo.modules.module', 'WARNING') as capture:
            manifest = load_manifest(self.module_name)
        self.assertEqual(manifest['license'], 'LGPL-3')
        self.assertIn("Missing `license` key", capture.output[0])


class TestExternalPythonDependency(BaseCase):

    def test_satisfied_version_constraint(self):
        with patch.object(module.importlib.metadata, 'version', return_value='2.0'):
            module.check_python_external_dependency('example>=1.0')

    def test_unsatisfied_version_constraint(self):
        with patch.object(module.importlib.metadata, 'version', return_value='1.0'):
            with self.assertRaisesRegex(module.MissingDependency, 'version mismatch'):
                module.check_python_external_dependency('example>=2.0')

    def test_missing_distribution_with_importable_module(self):
        not_found = module.importlib.metadata.PackageNotFoundError('ldap')
        with patch.object(module.importlib.metadata, 'version', side_effect=not_found), \
             patch.object(module.importlib, 'import_module'):
            module.check_python_external_dependency('ldap')

    def test_missing_distribution_and_module(self):
        not_found = module.importlib.metadata.PackageNotFoundError('example')
        with patch.object(module.importlib.metadata, 'version', side_effect=not_found), \
             patch.object(module.importlib, 'import_module', side_effect=ImportError):
            with self.assertRaisesRegex(module.MissingDependency, 'not installed'):
                module.check_python_external_dependency('example')

    def test_invalid_requirement(self):
        with self.assertRaisesRegex(ValueError, 'invalid external dependency specification'):
            module.check_python_external_dependency('example>>>1.0')

    def test_ignored_environment_marker(self):
        with patch.object(module.importlib.metadata, 'version') as version:
            module.check_python_external_dependency("example; python_version < '0'")
        version.assert_not_called()
