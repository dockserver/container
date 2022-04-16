"""
find docker-compose.yml files
"""

import fnmatch
import os
import sys
import glob
import shutil
import logging

path = "/opt/appdata/compose"
dirs = os.listdir( path )

def find_yml_files(path):
    """
    find docker-compose.yml files in path
    """
    matches = {}
    for root, dirs, filenames in os.walk(path, followlinks=True):
        for _ in set().union(fnmatch.filter(filenames, 'docker-compose.yml'), fnmatch.filter(filenames, 'docker-compose.yaml')):
            key = root.split('/')[-1]
            matches[key] = os.path.join(os.listdir(path), root)
    return match 

def get_readme_file(path):
    """
    find case insensitive readme.md in path and return the contents
    """
    readme = None
    for file in os.listdir( path ):
        if file.lower() == "readme.md" and os.path.isfile(os.path.join(path, file)):
            file = open(os.path.join(path, file))
            readme = file.read()
            file.close()
            break
    return readme

def get_logo_file(path):
    """
    find case insensitive logo.png in path and return the contents
    """
    logo = None
    for file in os.listdir( path ):
        if file.lower() == "logo.png" and os.path.isfile(os.path.join(path, file)):
            file = open(os.path.join(path, file))
            logo = file.read()
            file.close()
            break
    return logo

def get_env_files(path):
    """
    find case insensitive emv in path and return the contents
    """
    for root, dirnames, filenames in os.walk(path, followlinks=True):
        for filename in fnmatch.filter(filenames, '.env'):
            key = root.split('/')[-1]
            matches[key] = yield os.path.join(root, filename)
    return match
