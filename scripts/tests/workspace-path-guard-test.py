#!/usr/bin/env python3
"""使用独立临时登记表测试门禁，不改工作区或代码仓库。"""
import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


class WorkspaceGuardTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="workspace-guard-test-")
        self.root = Path(self.temp.name)
        self.workspace = self.root / "projects/测试项目"
        self.workspace.mkdir(parents=True)
        self.script = self.root / "scripts/workspace-path-guard.sh"
        self.script.parent.mkdir()
        shutil.copy2(Path(__file__).resolve().parents[1] / self.script.name, self.script)
        self.project = {"name": "测试项目", "aliases": ["test"], "flow": "v2",
                        "workspace": str(self.workspace), "appRepo": str(self.root / "code/app")}
        self.registry()

    def registry(self):
        (self.root / "workspace-registry.json").write_text(json.dumps({"projects": [self.project]}))

    def tearDown(self):
        self.temp.cleanup()

    def run_guard(self, *args):
        return subprocess.run(["bash", str(self.script), *map(str, args)], capture_output=True, text=True)

    def test_valid_alias_and_new_file(self):
        self.assertEqual(self.run_guard("check", "test", self.workspace / "v1/结果.md").returncode, 0)

    def test_other_project_prefix_traversal_relative_and_code_are_rejected(self):
        for target in [self.root / "projects/测试项目2/a.md", self.workspace / "../other/a.md",
                       Path("relative.md"), self.root / "code/app/projects/a.md"]:
            self.assertNotEqual(self.run_guard("check", "test", target).returncode, 0)

    def test_symlink_cannot_escape_and_audit_is_read_only(self):
        outside = self.root / "outside"
        outside.mkdir()
        (self.workspace / "escape").symlink_to(outside, target_is_directory=True)
        self.assertNotEqual(self.run_guard("check", "test", self.workspace / "escape/new.md").returncode, 0)
        self.assertNotEqual(self.run_guard("audit", "test").returncode, 0)
        self.assertTrue((self.workspace / "escape").is_symlink())

    def test_unknown_ambiguous_and_legacy_are_rejected(self):
        self.assertNotEqual(self.run_guard("audit", "missing").returncode, 0)
        self.project["flow"] = "v1-legacy"
        self.registry()
        self.assertNotEqual(self.run_guard("audit", "test").returncode, 0)
        (self.root / "workspace-registry.json").write_text(json.dumps({"projects": [self.project, self.project]}))
        self.assertNotEqual(self.run_guard("audit", "test").returncode, 0)

    def test_valid_audit_and_invalid_arguments(self):
        self.assertEqual(self.run_guard("audit", "test").returncode, 0)
        self.assertNotEqual(self.run_guard("check", "test").returncode, 0)
        self.assertNotEqual(self.run_guard("audit", "test", "extra").returncode, 0)


if __name__ == "__main__":
    unittest.main()
