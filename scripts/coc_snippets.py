import pathlib
import os
assert os.sep == '/', 'Not implemented yet for Windows system.'
import argparse
import json
from rich.pretty import pprint as print


friendlyy = pathlib.Path.home() / '.local/share/nvim/lazy/friendly-snippets'
snippets = friendlyy / 'snippets'


def symlink(link, file, create=True):
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


def friendly(create=True):
    for file in snippets.rglob('*.json'):
        link = file.relative_to(snippets)
        ft_index = 0
        if 'frameworks' in link.as_posix():
            ft_index = 1
        ft = link.as_posix().split('/')[ft_index].split('.')[0]
        link = snippets / link
        if link.name.split('.')[0] != ft:
            link = link.parent / link.name.split('.')[0] / f'{ft}.json'
            symlink(link, file, create)


def cython(create=True):
    cython = pathlib.Path.home() / '.local/share/nvim/lazy/cython-snips'
    python = snippets / 'python'
    for file in python.glob('*.json'):
        link = pathlib.Path(f"{cython / file.relative_to(snippets).as_posix().split('.')[0]}/cython.json")
        symlink(link, file, create)


def friendly2(create=True):
    fp = friendlyy / 'package.json'
    with open(fp, 'r') as j:
        fp = json.load(j)
    fp = fp['contributes']['snippets']
    for item in fp:
        file = friendlyy / item['path']
        language = item['language']
        if not isinstance(language, (list, tuple)):
            language = [language]
        links = []
        for l in language:
            filename = file.name.split('.')[0]
            link = file.parent / filename / f'{l}.json' if filename != l else file
            links.append(link)
        for link in links:
            symlink(link, file, create)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('fn')
    parser.add_argument('--no-create', action='store_true')
    args = parser.parse_args()

    if args.fn:
        eval(f'{args.fn}(create={not args.no_create})')
