# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools

DESCRIPTION="An easy to use library for the RELP protocol"
HOMEPAGE="http://www.librelp.com/"
SRC_URI="http://download.rsyslog.com/${PN}/${P}.tar.gz"

LICENSE="GPL-3+ doc? ( FDL-1.3 )"

# subslot = soname version
SLOT="0/0.4.0"

KEYWORDS="amd64 arm ~arm64 hppa sparc x86"
IUSE="debug doc +ssl +gnutls libressl openssl static-libs"
REQUIRED_USE="ssl? ( ^^ ( gnutls openssl ) )
	gnutls? ( ssl )
	openssl? ( ssl )
	libressl? ( openssl )"

RDEPEND="ssl? (
		gnutls? ( >=net-libs/gnutls-3.3.17.1:0= )
		openssl? (
			!libressl? ( dev-libs/openssl:0= )
			libressl? ( dev-libs/libressl:0= )
		)
	)"

DEPEND="ssl? (
		gnutls? ( >=net-libs/gnutls-3.3.17.1:0= )
		openssl? (
			!libressl? ( dev-libs/openssl:0= )
			libressl? ( dev-libs/libressl:0= )
		)
	)
	virtual/pkgconfig"

src_prepare() {
	sed -i \
		-e 's/ -g"/"/g' \
		configure.ac || die "sed failed"

	default

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-valgrind
		$(use_enable debug)
		$(use_enable gnutls tls)
		$(use_enable openssl tls-openssl)
		$(use_enable static-libs static)
	)

	econf "${myeconfargs[@]}"
}

src_test() {
	emake -j1 check
}

src_install() {
	local DOCS=( ChangeLog )
	use doc && local HTML_DOCS=( doc/relp.html )
	default

	if ! use static-libs; then
		find "${ED%/}"/usr/lib* -name '*.la' -delete || die
	fi
}
