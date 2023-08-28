import pathlib
import os
assert os.sep == '/', 'Not implemented yet for Windows system.'
import argparse


snippets = pathlib.Path.home() / '.local/share/nvim/lazy/friendly-snippets/snippets'


def symlink(link, json, create=True):
    try:
        if create:
            link.parent.mkdir(parents=True, exist_ok=True)
            link.symlink_to(json)
        else:
            link.unlink()
    except Exception as e:
        print(e)
        import pdb
        pdb.set_trace()  # HACK: Songli.Yu: ""


def friendly(create=True):
    for json in snippets.rglob('*.json'):
        link = json.relative_to(snippets)
        ft_index = 0
        if 'frameworks' in link.as_posix():
            ft_index = 1
        ft = link.as_posix().split('/')[ft_index].split('.')[0]
        link = snippets / link
        if link.name.split('.')[0] != ft:
            link = link.parent / link.name.split('.')[0] / f'{ft}.json'
            symlink(link, json, create)


def cython(create=True):
    cython = pathlib.Path.home() / '.local/share/nvim/lazy/cython-snips'
    python = snippets / 'python'
    for json in python.glob('*.json'):
        link = pathlib.Path(f"{cython / json.relative_to(snippets).as_posix().split('.')[0]}/cython.json")
        symlink(link, json, create)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('fn')
    parser.add_argument('--no-create', action='store_true')
    args = parser.parse_args()

    if args.fn:
        eval(f'{args.fn}(create={not args.no_create})')
