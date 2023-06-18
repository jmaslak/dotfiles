#!/usr/bin/env python3

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

import argparse
import os
import os.path
import shutil
import subprocess
import tempfile

from prompt_toolkit.shortcuts import radiolist_dialog,yes_no_dialog


def parse_arguments():
    """Get arguments from command line."""
    parser = argparse.ArgumentParser(description="Make scanned PDFs more usable")
    parser.add_argument('infile', help="Input filename")
    parser.add_argument('outfile', help="Output filename")

    args = parser.parse_args()
    return args


def rotate(fn_in, fn_out):
    """Prompt user for rotation info and rotate document."""
    choice = radiolist_dialog(
        title="File Rotation",
        text="Indicate how the document should be rotated",
        values=[
            (None, "None"),
            ("1-endeast", "Clockwise"),
            ("1-endwest", "Anti-Clockwise"),
            ("1-endsouth", "180 Degrees"),
        ],
    ).run()

    if choice is None:
        shutil.copy(fn_in, fn_out)
    else:
        subprocess.check_call(["pdftk", fn_in, "cat", choice, "output", fn_out])


def split_pages(fn_in, fn_out):
    """Split pages in scan."""
    choice = yes_no_dialog(
        title="Page Split",
        text="Do you want to split each input page into two output pages?",
    ).run()

    if not choice:
        shutil.copy(fn_in, fn_out)
    else:
        subprocess.check_call(["mutool", "poster", "-x", "2", fn_in, fn_out])


def remove_pages(fn_in, fn_out):
    """Remove pages in scan."""
    choice = radiolist_dialog(
        title="Remove Pages",
        text="Indicate which pages should be removed from the output",
        values=[
            (None, "None"),
            ("2-end", "First Page"),
            ("1-r2", "Last Page"),
            ("2-r2", "First and Last Page"),
        ],
    ).run()

    if not choice:
        shutil.copy(fn_in, fn_out)
    else:
        subprocess.check_call(["pdftk", fn_in, "cat", choice, "output", fn_out])


def ocr(fn_in, fn_out):
    """Prompt user to determine if they want OCR and, if so, OCR it."""
    choice = yes_no_dialog(
        title="OCR",
        text="Perform Optical Character Recognition?",
    ).run()

    if not choice:
        shutil.copy(fn_in, fn_out)
    else:
        subprocess.check_call(["ocrmypdf", fn_in, fn_out])


def evince(fn):
    """Open evince with filename provided, if X is running."""
    if os.environ.get('DISPLAY') is not None:
        subprocess.check_call(["evince", fn])


def main():
    """Main application function."""
    args = parse_arguments()

    tmpdir = tempfile.TemporaryDirectory()

    fn_in = args.infile
    fn_tmp1 = os.path.join(tmpdir.name, "work1.pdf")
    fn_tmp2 = os.path.join(tmpdir.name, "work2.pdf")
    fn_out = args.outfile

    shutil.copy(fn_in, fn_tmp1)

    rotate(fn_tmp1, fn_tmp2)
    shutil.copy(fn_tmp2, fn_tmp1)

    split_pages(fn_tmp1, fn_tmp2)
    shutil.copy(fn_tmp2, fn_tmp1)

    remove_pages(fn_tmp1, fn_tmp2)
    shutil.copy(fn_tmp2, fn_tmp1)

    ocr(fn_tmp1, fn_tmp2)

    shutil.copy(fn_tmp2, fn_out)
    evince(fn_out)


if __name__ == "__main__":
    main()

