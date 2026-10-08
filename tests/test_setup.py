"""Exercise newcomer setup in temporary checkouts, without network access.

Run with: python3 -m unittest discover -s tests
"""

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.checkout = self.root / "checkout"
        (self.checkout / "tools").mkdir(parents=True)
        shutil.copy(REPO / "Makefile", self.checkout)
        shutil.copy(REPO / "tools/check-deps", self.checkout / "tools")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        # Only expose the programs each test explicitly provides.
        self.program("sh", Path(shutil.which("sh")))
        self.program("uname", Path(shutil.which("uname")))
        self.program("mkdir", Path(shutil.which("mkdir")))
        self.program("dirname", Path(shutil.which("dirname")))
        self.program("echo", Path(shutil.which("echo")))
        self.env = dict(os.environ, PATH=str(self.bin), GIT_ALLOW_PROTOCOL="file")
        self.make = shutil.which("make")
        self.git = shutil.which("git")
        self.compiler = self.bin / "openscad"
        self.compiler.write_text(
            '#!/bin/sh\necho called >> compiler.log\n'
            'while [ "$#" -gt 0 ]; do\n'
            '  if [ "$1" = -o ]; then shift; : > "$1"; exit; fi\n'
            '  shift\ndone\n'
        )
        self.compiler.chmod(0o755)
        # Build dependency files suffice here; geometry is outside these tests.
        makefile = (self.checkout / "Makefile").read_text()
        for source in re.findall(r"\$\(SRC_DIR\)/([\w/.-]+\.scad)", makefile):
            self.file("src/" + source)

    def program(self, name, executable):
        (self.bin / name).symlink_to(executable)

    def file(self, name):
        path = self.checkout / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.touch()

    def run_make(self, *targets):
        return subprocess.run(
            [self.make, *targets, "OPENSCAD_BIN=" + str(self.compiler)],
            cwd=self.checkout, env=self.env, text=True, capture_output=True,
        )

    def test_missing_bosl_stops_parallel_build_with_recovery_command(self):
        result = self.run_make("-j4", "spool.stl", "pi_mount.stl")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git submodule update --init --recursive", result.stderr)
        self.assertFalse((self.checkout / "compiler.log").exists())

    def test_missing_openscad_explains_override(self):
        self.file("src/lib/BOSL2/std.scad")
        self.compiler.unlink()
        result = self.run_make("spool.stl")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("OPENSCAD_BIN=/path/to/openscad", result.stderr)

    def test_existing_stl_is_checked_without_rebuilding(self):
        self.file("src/lib/BOSL2/std.scad")
        self.file("stl/spool.stl")
        result = self.run_make("spool.stl")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.checkout / "compiler.log").exists())
        (self.checkout / "src/lib/BOSL2/std.scad").unlink()
        self.assertNotEqual(self.run_make("spool.stl").returncode, 0)

    def test_nested_model_exports_and_creates_output_directory(self):
        self.file("src/lib/BOSL2/std.scad")
        self.file("src/refwinch/conventional_winch.scad")
        result = self.run_make("stl/refwinch/conventional_winch.stl")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.checkout / "stl/refwinch/conventional_winch.stl").exists())

    def test_pdf_and_all_fail_before_rendering_when_pdf_tools_are_missing(self):
        self.file("src/lib/BOSL2/std.scad")
        for target in ("layout_letter.pdf", "layout_a4.pdf", "all"):
            with self.subTest(target=target):
                result = self.run_make("-j4", target)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("CairoSVG", result.stderr)
                self.assertIn("Ghostscript", result.stderr)
                self.assertFalse((self.checkout / "compiler.log").exists())

    def test_default_target_remains_letter_layout(self):
        self.file("src/lib/BOSL2/std.scad")
        result = self.run_make("-n")
        self.assertIn('check-deps layout', result.stdout)
        self.assertIn("layout_letter.pdf", result.stdout)

    def test_layout_check_passes_with_all_required_programs(self):
        self.file("src/lib/BOSL2/std.scad")
        for program in ("cairosvg", "sed", "gs"):
            self.program(program, self.compiler)
        result = self.run_make("check-layout-deps")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_setup_recovers_plain_clone_and_keeps_pinned_version(self):
        def git(cwd, *args):
            return subprocess.check_output(
                [self.git, "-c", "user.name=Setup Test", "-c", "user.email=setup@example.invalid", *args],
                cwd=cwd, env=dict(os.environ, GIT_ALLOW_PROTOCOL="file"),
                text=True, stderr=subprocess.DEVNULL,
            ).strip()

        library = self.root / "library"
        library.mkdir()
        git(library, "init")
        (library / "std.scad").write_text("// Pinned test library\n")
        git(library, "add", ".")
        git(library, "commit", "-m", "Initial library")
        pinned = git(library, "rev-parse", "HEAD")
        git(self.checkout, "init")
        git(self.checkout, "submodule", "add", str(library), "src/lib/BOSL2")
        git(self.checkout, "add", ".")
        git(self.checkout, "commit", "-m", "Test project")
        clone = self.root / "plain-clone"
        git(self.root, "clone", str(self.checkout), str(clone))
        self.assertFalse((clone / "src/lib/BOSL2/std.scad").exists())
        (library / "std.scad").write_text("// New upstream library\n")
        git(library, "commit", "-am", "Upstream change")
        for _ in range(2):
            result = subprocess.run(
                [self.make, "setup"], cwd=clone,
                env=dict(os.environ, GIT_ALLOW_PROTOCOL="file"),
                text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(git(clone / "src/lib/BOSL2", "rev-parse", "HEAD"), pinned)
            self.assertTrue((clone / "src/lib/BOSL2/std.scad").is_file())


if __name__ == "__main__":
    unittest.main()
