import os
assert os.sep == '/', 'Not implemented yet for Windows system.'
import pathlib
import argparse
import json
import contextlib


FRIENDLY = pathlib.Path.home() / '.local/share/nvim/lazy/friendly-snippets'
CYTHON = pathlib.Path.home() / '.local/share/nvim/lazy/cython-snips'


def _symlink(link, file, create=True):
    with contextlib.suppress(Exception):
        if create:
            link.parent.mkdir(parents=True, exist_ok=True)
            link.symlink_to(file)
            return
        link.unlink()


def _generator():
    with open(FRIENDLY / 'package.json', 'r') as j:
        package = json.load(j)
    for item in package['contributes']['snippets']:
        file = FRIENDLY / item['path']
        languages = item['language']
        if not isinstance(languages, (list, tuple)):
            languages = [languages]
        for language in languages:
            yield file, language


def friendly(create=True):
    for file, language in _generator():
        links = []
        filename = file.stem
        if filename != language:
            link = file.parent / filename / f'{language}.json'
            links.append(link)
        for link in links:
            _symlink(link, file, create)


def cython(create=True):
    package_json = CYTHON / 'package.json'
    package = {
        'contributes': {
            'snippets': [
                {
                    'language': 'cython',
                    'path': 'cython.json'
                }
            ]
        }
    }
    for file, language in _generator():
        if redundancies := list(CYTHON.glob(f'**/*{language}.json')):
            for redundancy in redundancies:
                redundancy.unlink()
        if language == 'python':
            link = CYTHON / file.relative_to(FRIENDLY).parent / file.stem / 'cython.json'
            package['contributes']['snippets'].append({
                'language': 'cython',
                'path': link.relative_to(CYTHON).as_posix()
            })
            _symlink(link, file, create)

    package_json.parent.mkdir(parents=True, exist_ok=True)
    with open(package_json, 'w') as j:
        json.dump(package, j)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('fn')
    parser.add_argument('--no-create', action='store_true')
    args = parser.parse_args()

    if args.fn:
        eval(f'{args.fn}(create={not args.no_create})')
