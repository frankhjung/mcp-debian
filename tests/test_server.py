import os
import sys
from pathlib import Path

import pytest

sys.path.insert(0, os.path.abspath(os.path.dirname(os.path.dirname(__file__))))
from server import get_version, list_directory, read_file


def test_list_directory_success(tmp_path: Path):
    (tmp_path / "file1.txt").touch()
    (tmp_path / "file2.txt").touch()
    (tmp_path / "subdir").mkdir()

    items = list_directory(str(tmp_path))

    assert "file1.txt" in items
    assert "file2.txt" in items
    assert "subdir" in items
    assert len(items) == 3


def test_list_directory_failure():
    items = list_directory("/path/to/non/existent/dir")

    assert len(items) == 1
    assert items[0].startswith("Error listing directory:")


def test_read_file_success(tmp_path: Path):
    test_file = tmp_path / "test.txt"
    test_file.write_text("Hello, World!", encoding="utf-8")

    content = read_file(str(test_file))

    assert content == "Hello, World!"


def test_read_file_failure():
    content = read_file("/path/to/non/existent/file.txt")

    assert content.startswith("Error reading file:")


def test_get_version_success(monkeypatch: pytest.MonkeyPatch):
    os_release = (
        'PRETTY_NAME="Debian GNU/Linux 13 (trixie)"\n'
        "DEBIAN_VERSION_FULL=13.4\n"
        "ID=debian\n"
    )

    monkeypatch.setattr(Path, "read_text", lambda *args, **kwargs: os_release)  # type: ignore

    version = get_version()

    assert version == "Debian GNU/Linux 13 (trixie) 13.4"
