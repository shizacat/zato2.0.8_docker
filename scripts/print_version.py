#!/usr/bin/env python3

'''
	Выводит версию Zato из текущего репозитория
'''

import tempfile
import subprocess
import json
import os

tdir = tempfile.TemporaryDirectory()

def git(*args):
	f = open('temp.txt', 'w')
	return subprocess.check_call(['git'] + list(args), stdout=f)

git("clone", "https://github.com/zatosource/zato.git", tdir.name)

release_info_dir = os.path.join( tdir.name, 'code', 'release-info')
release = open(os.path.join(release_info_dir, 'release.json')).read()
release = json.loads(release)

git("--git-dir",os.path.join( tdir.name, '.git'), 'log', '-n', '1', '--pretty=format:"%H"')
revision = open(os.path.join('temp.txt')).read().split('"')[1][:8]

version = '{}.{}.{}+rev.{}'.format(release['major'], release['minor'], release['micro'], revision)
print(version)