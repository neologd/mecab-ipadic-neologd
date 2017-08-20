#!/usr/bin/env python2.7

import argparse
import datetime
import errno
import json
import logging
import os
import re
import shutil
import subprocess
import tempfile

logging.basicConfig(level=logging.DEBUG)


class MeCabPackageException(Exception):
    pass


MECAB_IPADIC_NEOLOGD_NAME = "mecab-ipadic-neologd"
MECAB_IPADIC_NEOLOGD_SUMMARY = "Neologism dictionary based on the language resources on the Web for mecab-ipadic"
MECAB_IPADIC_NEOLOGD_LICENSE = "Apache-2.0"
MECAB_IPADIC_NEOLOGD_VENDOR = "Toshinori Sato (@overlast) <overlasting@gmail.com>"
MECAB_IPADIC_NEOLOGD_MAINTAINER = "Linas Valiukas <shirshegsm@gmail.com>"
MECAB_IPADIC_NEOLOGD_URL = "https://github.com/pypt/mecab-ipadic-neologd-bintray"
MECAB_IPADIC_NEOLOGD_GIT_URL = MECAB_IPADIC_NEOLOGD_URL + ".git"
MECAB_IPADIC_NEOLOGD_DEPENDS_MECAB_VERSION = "0.996"
MECAB_IPADIC_NEOLOGD_CHANGELOG_FILE = 'ChangeLog'
MECAB_IPADIC_NEOLOGD_TAGS = [
    'mecab-ipadic',
    'named-entities',
    'dictionary',
    'furigana',
    'neologism-dictionary',
    'mecab',
    'language-resources',
    'japanese-language',
]
MECAB_IPADIC_NEOLOGD_DEB_DISTRIBUTION = 'xenial'

PATH_TO_ROOT = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')
MECAB_IPADIC_NEOLOGD_MISC_DOCS = [
    os.path.join(PATH_TO_ROOT, 'README.md'),
    os.path.join(PATH_TO_ROOT, 'README.ja.md'),
    os.path.join(PATH_TO_ROOT, MECAB_IPADIC_NEOLOGD_CHANGELOG_FILE),
    os.path.join(PATH_TO_ROOT, 'COPYING'),
]


# ---

def __run_command(command, cwd=None):
    line_buffered = 1
    process = subprocess.Popen(command,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT,
                               bufsize=line_buffered,
                               cwd=cwd)
    while True:
        output = process.stdout.readline()
        if len(output) == 0 and process.poll() is not None:
            break
        logging.info(output.strip())
    rc = process.poll()
    if rc > 0:
        raise MeCabPackageException("Process returned non-zero exit code %d" % rc)


def __temp_directory():
    """Return temporary directory on the same partition (to be able to hardlink stuff)."""
    return tempfile.mkdtemp()


def __mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


def create_tgz_package(input_dir, version, revision):
    temp_dir = __temp_directory()
    mecab_dirname = '%(name)s-%(version)s-%(revision)s' % {
        'name': MECAB_IPADIC_NEOLOGD_NAME,
        'version': version,
        'revision': revision,
    }
    temp_mecab_dir_path = os.path.join(temp_dir, mecab_dirname)
    os.mkdir(temp_mecab_dir_path)
    logging.debug('Temporary MeCab tarball directory: %s' % temp_mecab_dir_path)

    logging.info('Linking MeCab files to tarball directory...')
    for filename in os.listdir(input_dir):
        full_filename = os.path.join(input_dir, filename)
        if os.path.isfile(full_filename):
            os.link(full_filename, os.path.join(temp_mecab_dir_path, filename))

    logging.info('Linking documentation files to tarball directory...')
    for doc_file_path in MECAB_IPADIC_NEOLOGD_MISC_DOCS:
        os.link(doc_file_path, os.path.join(temp_mecab_dir_path, os.path.basename(doc_file_path)))

    tarball_filename = '%s.tgz' % mecab_dirname
    logging.info('Creating "%s"...' % tarball_filename)
    temp_mecab_tarball_path = os.path.join(temp_dir, tarball_filename)
    __run_command(['tar', '-czvf', temp_mecab_tarball_path, mecab_dirname], cwd=temp_dir)

    logging.info('Cleaning up temporary directory...')
    shutil.rmtree(temp_mecab_dir_path)

    logging.info('Resulting tarball: %s' % temp_mecab_tarball_path)
    return temp_mecab_tarball_path


def __fpm_common_flags(version, revision):
    return [
        '--verbose',
        '--input-type', 'dir',
        '--name', MECAB_IPADIC_NEOLOGD_NAME,
        '--version', version,
        '--iteration', revision,
        '--description', MECAB_IPADIC_NEOLOGD_SUMMARY,
        '--license', MECAB_IPADIC_NEOLOGD_LICENSE,
        '--vendor', MECAB_IPADIC_NEOLOGD_VENDOR,
        '--maintainer', MECAB_IPADIC_NEOLOGD_MAINTAINER,
        '--url', MECAB_IPADIC_NEOLOGD_URL,
        '--architecture', 'all',
        '--prefix', '/',
    ]


def create_deb_package(input_dir, version, revision):
    temp_dir = __temp_directory()
    deb_source_dir = os.path.join(temp_dir, 'deb')
    os.mkdir(deb_source_dir)

    deb_base_lib_dir = 'var/lib/mecab/dic/ipadic-neologd'
    deb_base_doc_dir = 'usr/share/doc/mecab-ipadic-neologd'

    lib_dir = os.path.join(deb_source_dir, deb_base_lib_dir)
    __mkdir_p(lib_dir)

    doc_dir = os.path.join(deb_source_dir, deb_base_doc_dir)
    __mkdir_p(doc_dir)

    logging.info('Linking MeCab files to library directory...')
    for filename in os.listdir(input_dir):
        full_filename = os.path.join(input_dir, filename)
        if os.path.isfile(full_filename):
            os.link(full_filename, os.path.join(lib_dir, filename))

    logging.info('Linking documentation files to documentation directory...')
    for doc_file_path in MECAB_IPADIC_NEOLOGD_MISC_DOCS:
        os.link(doc_file_path, os.path.join(doc_dir, os.path.basename(doc_file_path)))

    deb_name = '%(name)s_%(version)s-%(revision)s_all.deb' % {
        'name': MECAB_IPADIC_NEOLOGD_NAME,
        'version': version,
        'revision': revision,
    }
    deb_path = os.path.join(temp_dir, deb_name)

    after_install_path = os.path.join(temp_dir, 'after-install')
    with open(after_install_path, 'w') as after_install:
        after_install.write(
            'update-alternatives --install /var/lib/mecab/dic/debian mecab-dictionary /%s 100' % deb_base_lib_dir
        )

    after_remove_path = os.path.join(temp_dir, 'after-remove')
    with open(after_remove_path, 'w') as after_remove:
        after_remove.write('update-alternatives --remove mecab-dictionary /%s' % deb_base_lib_dir)

    logging.info('Creating %s...' % deb_name)
    fpm_command = ['fpm'] + __fpm_common_flags(version=version, revision=revision) + [
        '--output-type', 'deb',
        '--package', deb_path,
        '--chdir', deb_source_dir,
        '--depends', 'mecab (>= %s)' % MECAB_IPADIC_NEOLOGD_DEPENDS_MECAB_VERSION,
        '--category', 'misc',
        '--deb-priority', 'extra',
        '--deb-no-default-config-files',
        '--after-install', after_install_path,
        '--after-remove', after_remove_path,
    ]
    logging.debug(fpm_command)
    __run_command(fpm_command)

    logging.info('Cleaning up temporary directory...')
    shutil.rmtree(deb_source_dir)

    logging.info('Resulting .deb: %s' % deb_path)
    return deb_path


def create_rpm_package(input_dir, version, revision):
    temp_dir = __temp_directory()
    rpm_source_dir = os.path.join(temp_dir, 'rpm')
    os.mkdir(rpm_source_dir)

    lib_dir = os.path.join(rpm_source_dir, 'usr/lib64/mecab/dic/ipadic-neologd')
    __mkdir_p(lib_dir)

    doc_dir = os.path.join(rpm_source_dir, 'usr/share/doc/%s-%s' % (MECAB_IPADIC_NEOLOGD_NAME, version,))
    __mkdir_p(doc_dir)

    logging.info('Linking MeCab files to library directory...')
    for filename in os.listdir(input_dir):
        full_filename = os.path.join(input_dir, filename)
        if os.path.isfile(full_filename):
            os.link(full_filename, os.path.join(lib_dir, filename))

    logging.info('Linking documentation files to documentation directory...')
    for doc_file_path in MECAB_IPADIC_NEOLOGD_MISC_DOCS:
        os.link(doc_file_path, os.path.join(doc_dir, os.path.basename(doc_file_path)))

    rpm_name = '%(name)s_%(version)s-%(revision)s_all.rpm' % {
        'name': MECAB_IPADIC_NEOLOGD_NAME,
        'version': version,
        'revision': revision,
    }
    rpm_path = os.path.join(temp_dir, rpm_name)

    logging.info('Creating %s...' % rpm_name)
    fpm_command = ['fpm'] + __fpm_common_flags(version=version, revision=revision) + [
        '--output-type', 'rpm',
        '--package', rpm_path,
        '--chdir', rpm_source_dir,
        '--depends', 'mecab >= %s' % MECAB_IPADIC_NEOLOGD_DEPENDS_MECAB_VERSION,
        '--category', 'Applications/Text',
        '--rpm-os', 'linux',
    ]
    logging.debug(fpm_command)
    __run_command(fpm_command)

    logging.info('Cleaning up temporary directory...')
    shutil.rmtree(rpm_source_dir)

    logging.info('Resulting .rpm: %s' % rpm_path)
    return rpm_path


def __version_revision_from_version_tag(version_tag):
    version, revision = re.split('[\-_]', version_tag)
    return version, revision


def create_package(package_type, input_dir, version, revision):
    if not os.path.isfile(os.path.join(input_dir, 'sys.dic')):
        raise MeCabPackageException('Input directory "%s" does not contain build MeCab dictionary.' % input_dir)
    for misc_doc_file in MECAB_IPADIC_NEOLOGD_MISC_DOCS:
        if not os.path.isfile(misc_doc_file):
            raise MeCabPackageException('Misc. documentation file "%s" does not exist.' % misc_doc_file)

    if package_type == 'tgz':
        package_path = create_tgz_package(input_dir=input_dir, version=version, revision=revision)
    elif package_type == 'deb':
        package_path = create_deb_package(input_dir=input_dir, version=version, revision=revision)
    elif package_type == 'rpm':
        package_path = create_rpm_package(input_dir=input_dir, version=version, revision=revision)
    else:
        raise MeCabPackageException('Unknown package type "%s".' % package_type)

    if not os.path.isfile(package_path):
        MeCabPackageException('Created package "%s" does not exist.' % package_path)

    return package_path


def __bintray_descriptor_json(bintray_repository_name, bintray_username, version, revision, version_tag, package_path):
    package_dir = os.path.dirname(package_path)
    package_filename = os.path.basename(package_path)
    include_pattern = '%s/(%s)' % (package_dir, package_filename,)

    descriptor = {
        "package": {
            "name": MECAB_IPADIC_NEOLOGD_NAME,
            "repo": bintray_repository_name,
            "subject": bintray_username,
            "desc": MECAB_IPADIC_NEOLOGD_SUMMARY,
            "website_url": MECAB_IPADIC_NEOLOGD_URL,
            "vcs_url": MECAB_IPADIC_NEOLOGD_GIT_URL,
            "github_use_tag_release_notes": True,
            "github_release_notes_file": MECAB_IPADIC_NEOLOGD_CHANGELOG_FILE,
            "licenses": [
                MECAB_IPADIC_NEOLOGD_LICENSE
            ],
            "labels": MECAB_IPADIC_NEOLOGD_TAGS,
            "public_download_numbers": True,
            "public_stats": True,
        },

        "version": {
            "name": '%s-%s' % (version, revision,),
            "desc": "%s (%s)" % (version, revision,),
            "released": datetime.datetime.today().strftime('%Y-%m-%d'),
            "vcs_tag": version_tag,
            "gpgSign": True,
        },

        "files": [
            {
                "includePattern": include_pattern,
                "uploadPattern": "$1",
                "matrixParams": {
                    "override": 1,

                    # Used for .deb files only
                    "deb_distribution": MECAB_IPADIC_NEOLOGD_DEB_DISTRIBUTION,
                    "deb_component": 'main',
                    "deb_architecture": 'all',
                }
            }
        ],
        "publish": True
    }
    return json.dumps(descriptor)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Package MeCab dictionary.')
    parser.add_argument('--type', required=True, choices=['tgz', 'deb', 'rpm'], help='Package type.')
    parser.add_argument('--input_dir', required=True, help='Input directory with built MeCab dictionary.')
    parser.add_argument('--version_tag', required=True, help='Git version tag (version + revision), e.g. "20170814-1".')

    parser.add_argument('--bintray_descriptor_file', required=False, help='Bintray.com descriptor file to write.')
    parser.add_argument('--bintray_repository_name', required=False, help='Bintray.com repository name.')
    parser.add_argument('--bintray_username', required=False, help='Bintray.com username.')

    args = parser.parse_args()

    arg_version, arg_revision = re.split('[\-_]', args.version_tag)
    logging.debug('Version: %s, revision: %s' % (arg_version, arg_revision))

    logging.info('Creating "%s" package from "%s"...' % (args.type, args.input_dir,))
    pkg_path = create_package(package_type=args.type,
                              input_dir=args.input_dir,
                              version=arg_version,
                              revision=arg_revision)
    logging.info('Created package at "%s".' % pkg_path)

    if args.bintray_descriptor_file:
        logging.info('Creating Bintray.com descriptor to "%s"...' % args.bintray_descriptor_file)
        with open(args.bintray_descriptor_file, 'w') as bintray_descriptor:
            bintray_descriptor.write(
                __bintray_descriptor_json(
                    bintray_repository_name=args.bintray_repository_name,
                    bintray_username=args.bintray_username,
                    version=arg_version,
                    revision=arg_revision,
                    version_tag=args.version_tag,
                    package_path=pkg_path,
                )
            )
        logging.info('Created Bintray.com descriptor to "%s".' % args.bintray_descriptor_file)
