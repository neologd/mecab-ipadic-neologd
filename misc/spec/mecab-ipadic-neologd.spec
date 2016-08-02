# This spec file is very similar with mecab-ipadic
%global		debug_package	%{nil}
%global		__os_install_post	%{nil}
%define		majorver	0.0.5
%define		date		20160502
%define		mecabver	0.96
Name:		mecab-ipadic-neologd
Version:	%{majorver}.%{date}
Release:	1%{?dist}.0
Summary:	Neologism dictionary for MeCab

Group:		Applications/Text
License:	Apache License, Version 2.0
URL:		https://github.com/neologd/%{name}/tree/v%{majorver}
Source0:	https://github.com/neologd/%{name}/archive/v%{majorver}.tar.gz
Source3:	http://www.apache.org/licenses/LICENSE-2.0.txt
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:	mecab-devel >= %{mecabver}
BuildRequires:	curl diffutils file findutils glibc grep make openssl patch sed tar which xz
Requires:	mecab >= %{mecabver}
Provides:	mecab-dic-neologd

%description
mecab-ipadic-NEologd is customized system dictionary for MeCab.
This dictionary includes many neologisms (new word), which are
extracted from many language resources on the Web.
When you analyze the Web documents, it's better to use this
system dictionary and default one (ipadic) together.
This dictionary is for UTF-8 use.

%prep
%setup -q -n %{name}-%{majorver}

%build

%install
./bin/install-mecab-ipadic-neologd --prefix $RPM_BUILD_ROOT%{_libdir}/mecab/dic/ipadic-neologd --asuser --forceyes
%{__cp} -p %{SOURCE3} .

%clean
%{__rm} -rf $RPM_BUILD_ROOT

%post
# Note: post should be okay. mecab-dic-neologd expects that
# mecab is installed in advance.
if test -f %{_sysconfdir}/mecabrc ; then
	%{__sed} -i -e 's|^dicdir.*|dicdir = %{_libdir}/mecab/dic/ipadic-neologd|' \
		%{_sysconfdir}/mecabrc || :
fi

%files
%defattr(-,root,root,-)
%doc COPYING LICENSE* ChangeLog README.ja.md README.md
%{_libdir}/mecab/dic/ipadic-neologd/

%changelog
* Tue Aug 2 2016 YAMAMOTO Takashi <yamachan@piwikjapan.org> - 0.0.5.20160502-1
- Initial packaging, based on mecab-ipadic spec file
