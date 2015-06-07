# -*- coding: utf-8 -*-

from . import git

def get_version(*args, **kwargs):
    """Derives a PEP386-compliant version number from VERSION."""
    if 'version' in kwargs:
        version = kwargs['version']
    elif args:
        version = args[0]
    else:
        version = (0, 1, 0, 'alpha', 0)

    assert len(version) == 5
    assert version[3] in ('alpha', 'beta', 'rc', 'final')

    # Now build the two parts of the version number:
    # main = X.Y[.Z]
    # sub = .devN - for pre-alpha releases
    #     | {a|b|c}N - for alpha, beta and rc releases

    parts = 2 if version[2] == 0 else 3
    main = '.'.join(str(x) for x in version[:parts])

    sub = ''
    if version[3] == 'alpha' and version[4] == 0:
        git_revision = git.get_git_changeset()[4:]
        if git_revision != 'unknown':
            sub = '.dev{revision}'.format(revision=git_revision)
        else:
            sub = '.dev'

    elif version[3] != 'final':
        mapping = {'alpha': 'a', 'beta': 'b', 'rc': 'c'}
        sub = mapping[version[3]] + str(version[4])

    return main + sub
