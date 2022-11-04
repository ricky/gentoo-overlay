# Copyright 2019-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd tmpfiles unpacker xdg-utils

DESCRIPTION="NordVPN CLI tool for Linux"
HOMEPAGE="https://nordvpn.com"
BASE_URI="https://repo.nordvpn.com/deb/${PN}/debian/pool/main"
SRC_URI="
	amd64? ( "${BASE_URI}/${P/-/_}_amd64.deb" )
	arm? ( "${BASE_URI}/${P/-/_}_armhf.deb" )
	x86? ( "${BASE_URI}/${P/-/_}_i386.deb" )
"

LICENSE="NordVPN"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="nordlynx systemd"
RESTRICT="mirror strip"

RDEPEND="
	acct-group/nordvpn
	dev-libs/libxslt[crypt]
	net-firewall/iptables
	sys-apps/iproute2[iptables]
	sys-apps/net-tools
	sys-process/procps
	nordlynx? ( net-vpn/wireguard-tools )
	systemd? ( sys-apps/systemd )
"

S="${WORKDIR}"

src_unpack() {
	unpack_deb "${A}"
}

src_prepare() {
	default
	rm _gpgbuilder || die
	use !systemd && ( rm -rf usr/lib/systemd || die )
	mv usr/share/doc/nordvpn/changelog.gz .
	gunzip changelog.gz
	mv usr/share/man/man1/${PN}.1.gz .
	gunzip ${PN}.1.gz
	rm -rf usr/share/man \
	   usr/share/doc \
	   etc/init.d
}

src_install() {
	dodoc changelog
	rm changelog
	doman ${PN}.1
	rm ${PN}.1

	if use systemd; then
		systemd_dounit "${S}/usr/lib/systemd/system/nordvpnd.service"
		rm "${S}/usr/lib/systemd/system/nordvpnd.service"
	else
		newinitd "${FILESDIR}/${PN}.initd" ${PN}
	fi

	mkdir -p "${ED}"
	cp -r . "${ED}/"
}

pkg_postinst() {
	tmpfiles_process "${PN}.conf"
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "To allow a user to manage vpn connections, add them to the ${PN} group:"
	elog
	elog "  usermod -aG nordvpn <username>"
	elog
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
