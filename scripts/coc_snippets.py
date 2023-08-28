import pathlib
import os
assert os.sep == '/', 'Not implemented yet for Windows system.'
import argparse
import json
from rich.pretty import pprint as print


FRIENDLY = pathlib.Path.home() / '.local/share/nvim/lazy/friendly-snippets'
FRIENDLY_PACKAGE = FRIENDLY / 'package.json'
snippets = FRIENDLY / 'snippets'


def _symlink(link, file, create=True):
    try:
        if create:
            link.parent.mkdir(parents=True, exist_ok=True)
            link.symlink_to(file)
        else:
            link.unlink()
    except Exception as e:
        # print(e)
        # import pdb
        # pdb.set_trace()  # HACK: Songli.Yu: ""
        pass


def _package(package):
    with open(package, 'r') as j:
        package = json.load(j)
    return package['contributes']['snippets']


def cython2(create=True):
    cython = pathlib.Path.home() / '.local/share/nvim/lazy/cython-snips'
    python = snippets / 'python'
    for file in python.glob('*.json'):
        link = pathlib.Path(f"{cython / file.relative_to(snippets).as_posix().split('.')[0]}/cython.json")
        _symlink(link, file, create)


def _generator():
    for item in _package(FRIENDLY_PACKAGE):
        file = FRIENDLY / item['path']
        language = item['language']
        yield file, language


def friendly(create=True):
    for file, language in _generator():
        if not isinstance(language, (list, tuple)):
            language = [language]
        links = []
        for l in language:
            filename = file.stem
            if filename != l:
                link = file.parent / filename / f'{l}.json'
                links.append(link)
        for link in links:
            _symlink(link, file, create)


def cython(create=True):
    for file, language in _generator():
        if language == 'python':
            print(file.relative_to(FRIENDLY))
            # TODO:
            # link =


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('fn')
    parser.add_argument('--no-create', action='store_true')
    args = parser.parse_args()

    if args.fn:
        eval(f'{args.fn}(create={not args.no_create})')
