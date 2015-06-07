# -*- coding: utf-8 -*-

import os.path
import subprocess
import datetime

from . import encoding

def get_git_changeset(path=None):
    """
    Returns a numeric identifier of the latest Git changeset.
    Since the Git revision hash does not fulfil the requirements
    of PEP 386, the UTC timestamp in YYYYMMDDHHMMSS format is used
    instead. This value is not guaranteed to be unique, however the
    likeliness of collisions is small enough to be acceptable for
    the purpose of building version numbers.
    """
    if path is None:
        path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    # run `git show` in the project's root directory and grab its output from stdout
    try:
        with subprocess.Popen(
            'git show --pretty=format:%ct --quiet HEAD',
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True,
            cwd=path,
            universal_newlines=True
        ) as git_show:
            timestamp = encoding.to_str(git_show.communicate()[0]).partition('\n')[0]
    except OSError:
        timestamp = None

    try:
        timestamp = datetime.datetime.utcfromtimestamp(int(timestamp))
    except (ValueError, TypeError):
        return 'GIT-unknown'

    return 'GIT-{0:>s}'.format(timestamp.strftime('%Y%m%d%H%M%S'))
