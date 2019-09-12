#!/usr/bin/env python3

"""
Create .tgz / .deb / .rpm packages of mecab-ipadic-neologd.

Requires fpm:

    gem install --no-ri --no-rdoc fpm

"""
from abc import ABC, ABCMeta, abstractmethod
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
from typing import Optional, List

logging.basicConfig(level=logging.DEBUG)


class MeCabPackageException(Exception):
    """Exception thrown when package generation fails."""
    pass


class PackageConfig(object):
    """Package configuration."""

    @classmethod
    def name(cls) -> str:
        """
        Return package name
        :return: Package name.
        """
        return "mecab-ipadic-neologd"

    @classmethod
    def summary(cls) -> str:
        """
        Return package summary.
        :return: Package summary.
        """
        return "(Unofficial build) Neologism dictionary based on the language resources on the Web for mecab-ipadic"

    @classmethod
    def license(cls) -> str:
        """
        Return package license.
        :return: Package license.
        """
        return "Apache-2.0"

    @classmethod
    def vendor(cls) -> str:
        """
        Return package vendor.
        :return: Package vendor.
        """
        return "Toshinori Sato (@overlast) <overlasting@gmail.com>"

    @classmethod
    def maintainer(cls) -> str:
        """
        Return package maintainer.
        :return: Package maintainer.
        """
        return "Linas Valiukas <linas@media.mit.edu>"

    @classmethod
    def url(cls) -> str:
        """
        Return package URL.
        :return: Package URL.
        """
        return "https://github.com/pypt/mecab-ipadic-neologd-publish-builds"

    @classmethod
    def git_url(cls) -> str:
        """
        Return package Git URL.
        :return: Package Git URL.
        """
        return cls.url() + ".git"

    @classmethod
    def depends_mecab_version(cls) -> str:
        """
        Return MeCab version the package depends on.
        :return: MeCab version the package depends on.
        """
        return "0.996"

    @classmethod
    def changelog_file(cls) -> str:
        """
        Return changelog filename.
        :return: Changelog filename.
        """
        return 'ChangeLog'

    @classmethod
    def tags(cls) -> List[str]:
        """
        Return list of package tags.
        :return: List of package tags.
        """
        return [
            'mecab-ipadic',
            'named-entities',
            'dictionary',
            'furigana',
            'neologism-dictionary',
            'mecab',
            'language-resources',
            'japanese-language',
        ]

    @classmethod
    def misc_docs(cls) -> List[str]:
        """
        Return list of absolute paths to documentation files.
        :return: List of absolute paths to documentation files.
        """
        path_to_root = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')
        return [
            os.path.join(path_to_root, 'README.md'),
            os.path.join(path_to_root, 'README.ja.md'),
            os.path.join(path_to_root, cls.changelog_file()),
            os.path.join(path_to_root, 'COPYING'),
        ]


class PackageGenerator(object, metaclass=ABCMeta):
    """Abstract package generator."""

    @classmethod
    def _run_command(cls, command: List[str], cwd: Optional[str] = None) -> None:
        """
        Run command, forward output to logger.

        :param command: Command to run.
        :param cwd: Directory to change to before running a command; None if the directory shouldn't be changed.
        """
        line_buffered = 1
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=line_buffered,
            cwd=cwd,
        )

        while True:
            output = process.stdout.readline()
            if len(output) == 0 and process.poll() is not None:
                break
            logging.info(output.strip())
        rc = process.poll()
        if rc > 0:
            raise MeCabPackageException("Process returned non-zero exit code %d" % rc)

    @classmethod
    def _mkdir_p(cls, path: str) -> None:
        """
        Create directory with parent directories.

        :param path: Path of directories to create.
        """
        try:
            os.makedirs(path)
        except OSError as exc:  # Python >2.5
            if exc.errno == errno.EEXIST and os.path.isdir(path):
                pass
            else:
                raise

    @classmethod
    def _link_dictionaries_and_docs(cls, input_dir: str, lib_dir: str, doc_dir: str, config: PackageConfig) -> None:
        """
        Hardlink dictionary files from input directory and documentation to target directory.
        :param input_dir: Input directory with dictionary files.
        :param lib_dir: Output library directory where dictionary files should reside.
        :param doc_dir: Output documentation directory where docs should reside
        """
        cls._mkdir_p(lib_dir)
        cls._mkdir_p(doc_dir)

        logging.info('Linking MeCab files to library directory...')
        for filename in os.listdir(input_dir):
            full_filename = os.path.join(input_dir, filename)
            if os.path.isfile(full_filename):
                os.link(full_filename, os.path.join(lib_dir, filename))

        logging.info('Linking documentation files to documentation directory...')
        for doc_file_path in config.misc_docs():
            os.link(doc_file_path, os.path.join(doc_dir, os.path.basename(doc_file_path)))

    @classmethod
    @abstractmethod
    def package_type(cls) -> str:
        """
        Return package type to use for arguments.
        :return: Package type to use for arguments, e.g. "tgz".
        """
        raise NotImplemented("Abstract method.")

    @classmethod
    @abstractmethod
    def expected_extension(cls) -> str:
        """
        Return expected extension for this package type.
        :return: Expected extension for this package type, e.g. ".tgz".
        """
        raise NotImplemented("Abstract method.")

    @classmethod
    @abstractmethod
    def generate_package(cls,
                         input_dir: str,
                         version: str,
                         revision: str,
                         output_file: str,
                         config: PackageConfig) -> None:
        """
        Generate package of built dictionary.

        :param input_dir: Directory with staged dictionary to use for packaging.
        :param version: Package version, e.g. "20170814".
        :param revision: Package revision, e.g. "1".
        :param output_file: Output file to write the package to, e.g. "test.tgz".
        :param config: Package configuration.
        """
        raise NotImplemented("Abstract method.")


class TGZPackageGenerator(PackageGenerator):
    """.tgz package generator."""

    @classmethod
    def package_type(cls) -> str:
        return 'tgz'

    @classmethod
    def expected_extension(cls) -> str:
        return '.tgz'

    @classmethod
    def generate_package(cls,
                         input_dir: str,
                         version: str,
                         revision: str,
                         output_file: str,
                         config: PackageConfig) -> None:
        temp_dir = tempfile.mkdtemp()
        mecab_dirname = '%(name)s-%(version)s-%(revision)s' % {
            'name': config.name(),
            'version': version,
            'revision': revision,
        }
        lib_doc_dir = os.path.join(temp_dir, mecab_dirname)
        os.mkdir(lib_doc_dir)
        logging.debug('Temporary MeCab tarball directory: %s' % lib_doc_dir)

        cls._link_dictionaries_and_docs(input_dir=input_dir, lib_dir=lib_doc_dir, doc_dir=lib_doc_dir, config=config)

        if os.path.isfile(output_file):
            logging.info("Removing previously built TGZ package at %s..." % output_file)
            os.unlink(output_file)

        logging.info('Creating "%s"...' % output_file)

        cls._run_command(['tar', '-czvf', output_file, mecab_dirname], cwd=temp_dir)

        logging.info('Cleaning up temporary directory...')
        shutil.rmtree(lib_doc_dir)

        logging.info('Resulting tarball: %s' % output_file)


class FPMBasedPackageGenerator(PackageGenerator, ABC):
    """Abstract FPM-based package generator."""

    @classmethod
    def _fpm_common_flags(cls, version: str, revision: str, config: PackageConfig) -> List[str]:
        return [
            '--verbose',
            '--input-type', 'dir',
            '--name', config.name(),
            '--version', version,
            '--iteration', revision,
            '--description', config.summary(),
            '--license', config.license(),
            '--vendor', config.vendor(),
            '--maintainer', config.maintainer(),
            '--url', config.url(),
            '--architecture', 'all',
            '--prefix', '/',
        ]


class DEBPackageGenerator(FPMBasedPackageGenerator):
    """.deb package generator."""

    @classmethod
    def package_type(cls) -> str:
        return 'deb'

    @classmethod
    def expected_extension(cls) -> str:
        return '.deb'

    @classmethod
    def generate_package(cls,
                         input_dir: str,
                         version: str,
                         revision: str,
                         output_file: str,
                         config: PackageConfig) -> None:
        deb_source_dir = tempfile.mkdtemp()

        deb_base_lib_dir = 'var/lib/mecab/dic/ipadic-neologd'
        deb_base_doc_dir = 'usr/share/doc/mecab-ipadic-neologd'

        lib_dir = os.path.join(deb_source_dir, deb_base_lib_dir)
        doc_dir = os.path.join(deb_source_dir, deb_base_doc_dir)

        cls._link_dictionaries_and_docs(input_dir=input_dir, lib_dir=lib_dir, doc_dir=doc_dir, config=config)

        deb_name = '%(name)s_%(version)s-%(revision)s_all.deb' % {
            'name': config.name(),
            'version': version,
            'revision': revision,
        }

        if os.path.isfile(output_file):
            logging.info("Removing previously built DEB package at %s..." % output_file)
            os.unlink(output_file)

        after_install_path = os.path.join(tempfile.mkdtemp(), 'after-install')
        with open(after_install_path, 'w') as after_install:
            after_install.write(
                'update-alternatives --install /var/lib/mecab/dic/debian mecab-dictionary /%s 100' % deb_base_lib_dir
            )

        after_remove_path = os.path.join(tempfile.mkdtemp(), 'after-remove')
        with open(after_remove_path, 'w') as after_remove:
            after_remove.write('update-alternatives --remove mecab-dictionary /%s' % deb_base_lib_dir)

        logging.info('Creating %s...' % deb_name)
        fpm_command = ['fpm'] + cls._fpm_common_flags(version=version, revision=revision, config=config) + [
            '--output-type', 'deb',
            '--package', output_file,
            '--chdir', deb_source_dir,
            '--depends', 'mecab (>= %s)' % config.depends_mecab_version(),
            '--category', 'misc',
            '--deb-priority', 'extra',
            '--deb-no-default-config-files',
            '--after-install', after_install_path,
            '--after-remove', after_remove_path,
        ]
        logging.debug(fpm_command)
        cls._run_command(fpm_command)

        logging.info('Cleaning up temporary directory...')
        shutil.rmtree(deb_source_dir)

        logging.info('Resulting .deb: %s' % output_file)


class RPMPackageGenerator(FPMBasedPackageGenerator):
    """.rpm package generator."""

    @classmethod
    def package_type(cls) -> str:
        return 'rpm'

    @classmethod
    def expected_extension(cls) -> str:
        return '.rpm'

    @classmethod
    def generate_package(cls,
                         input_dir: str,
                         version: str,
                         revision: str,
                         output_file: str,
                         config: PackageConfig) -> None:
        rpm_source_dir = tempfile.mkdtemp()

        lib_dir = os.path.join(rpm_source_dir, 'usr/lib64/mecab/dic/ipadic-neologd')
        doc_dir = os.path.join(rpm_source_dir, 'usr/share/doc/%s-%s' % (config.name(), version,))

        cls._link_dictionaries_and_docs(input_dir=input_dir, lib_dir=lib_dir, doc_dir=doc_dir, config=config)

        rpm_name = '%(name)s_%(version)s-%(revision)s_all.rpm' % {
            'name': config.name(),
            'version': version,
            'revision': revision,
        }

        if os.path.isfile(output_file):
            logging.info("Removing previously built RPM package at %s..." % output_file)
            os.unlink(output_file)

        logging.info('Creating %s...' % rpm_name)
        fpm_command = ['fpm'] + cls._fpm_common_flags(version=version, revision=revision, config=config) + [
            '--output-type', 'rpm',
            '--package', output_file,
            '--chdir', rpm_source_dir,
            '--depends', 'mecab >= %s' % config.depends_mecab_version(),
            '--category', 'Applications/Text',
            '--rpm-os', 'linux',
        ]
        logging.debug(fpm_command)
        cls._run_command(fpm_command)

        logging.info('Cleaning up temporary directory...')
        shutil.rmtree(rpm_source_dir)

        logging.info('Resulting .rpm: %s' % output_file)


def bintray_descriptor_json(bintray_repository_name: str,
                            bintray_subject: str,
                            version: str,
                            revision: str,
                            version_tag: str,
                            package_path: str,
                            config: PackageConfig) -> str:
    """
    Generate and return Bintray descriptor JSON for a package.

    :param bintray_repository_name: Bintray repository name, e.g. "mecab-ipadic-neologd-tgz".
    :param bintray_subject: Bintray subject (user or organization), e.g. "neologd-unofficial".
    :param version: Package version, e.g. "20170814".
    :param revision: Package revision, e.g. "1".
    :param version_tag: Git tag, e.g. "20170814" or "20170814-1".
    :param package_path: Path to package to upload.
    :param config: Package configuration.
    :return: Bintray descriptor JSON.
    """
    package_dir = os.path.dirname(package_path)
    package_filename = os.path.basename(package_path)
    include_pattern = '%s/(%s)' % (package_dir, package_filename,)

    descriptor = {
        "package": {
            "name": config.name(),
            "repo": bintray_repository_name,
            "subject": bintray_subject,
            "desc": config.summary(),
            "website_url": config.url(),
            "vcs_url": config.git_url(),
            "github_use_tag_release_notes": True,
            "github_release_notes_file": config.changelog_file(),
            "licenses": [
                config.license(),
            ],
            "labels": config.tags(),
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
                    "deb_distribution": 'stable',
                    "deb_component": 'main',
                    "deb_architecture": 'all',
                }
            }
        ],
        "publish": True,
    }
    return json.dumps(descriptor)


def main():
    package_generator_classes = [
        TGZPackageGenerator,
        DEBPackageGenerator,
        RPMPackageGenerator,
    ]

    parser = argparse.ArgumentParser(description='Generate mecab-ipadic-neologd package.')

    parser.add_argument('--type', required=True, type=str,
                        choices=[e.package_type() for e in package_generator_classes],
                        help='Package type to build.')
    parser.add_argument('--input_dir', required=True, type=str,
                        help='Input directory with pre-built MeCab dictionary, i.e. the directory with "sys.dic".')
    parser.add_argument('--version_tag', required=True, type=str,
                        help='Git version tag, e.g. "20170814" or "20170814-1".')
    parser.add_argument('--output_file', required=True, type=str,
                        help="Output package file.")

    parser.add_argument('--bintray_descriptor_file', required=False, type=str,
                        help="Bintray descriptor file to write; if unset, won't create descriptor.")
    parser.add_argument('--bintray_repository_name', required=False, type=str,
                        help='Bintray repository name, e.g. "mecab-ipadic-neologd-tgz".')
    parser.add_argument('--bintray_subject', required=False, type=str,
                        help='Bintray subject (user or organization), e.g. "neologd-unofficial".')

    args = parser.parse_args()

    package_generator = next((x for x in package_generator_classes if x.package_type() == args.type), None)
    if not package_generator:
        parser.error("Invalid package type: %s" % args.package_type)

    if args.bintray_descriptor_file:
        if not (args.bintray_repository_name and args.bintray_subject):
            parser.error("Please provide Bintray descriptor file path, repository name and subject.")

    if not args.output_file.endswith(package_generator.expected_extension()):
        parser.error("Output file does not end with expected extension '%s'." % package_generator.expected_extension())

    config = PackageConfig()

    if not os.path.isfile(os.path.join(args.input_dir, 'sys.dic')):
        raise MeCabPackageException('Input directory "%s" does not contain build MeCab dictionary.' % args.input_dir)
    for misc_doc_file in config.misc_docs():
        if not os.path.isfile(misc_doc_file):
            raise MeCabPackageException('Misc. documentation file "%s" does not exist.' % misc_doc_file)

    if '-' in args.version_tag or '_' in args.version_tag:
        arg_version, arg_revision = re.split(r'[\-_]', args.version_tag)
    else:
        arg_version = args.version_tag
        arg_revision = '1'

    logging.debug('Version: %s, revision: %s' % (arg_version, arg_revision))

    logging.info('Creating "%s" package from "%s"...' % (args.type, args.input_dir,))
    package_generator.generate_package(
        input_dir=args.input_dir,
        version=arg_version,
        revision=arg_revision,
        output_file=args.output_file,
        config=config,
    )

    if not os.path.isfile(args.output_file):
        MeCabPackageException('Created package "%s" does not exist.' % args.output_file)
    logging.info('Created package at "%s".' % args.output_file)

    if args.bintray_descriptor_file:
        logging.info('Creating Bintray descriptor to "%s"...' % args.bintray_descriptor_file)
        with open(args.bintray_descriptor_file, 'w') as bintray_descriptor:
            bintray_descriptor.write(
                bintray_descriptor_json(
                    bintray_repository_name=args.bintray_repository_name,
                    bintray_subject=args.bintray_subject,
                    version=arg_version,
                    revision=arg_revision,
                    version_tag=args.version_tag,
                    package_path=args.output_file,
                    config=config,
                )
            )
        logging.info('Created Bintray descriptor to "%s".' % args.bintray_descriptor_file)


if __name__ == '__main__':
    main()
