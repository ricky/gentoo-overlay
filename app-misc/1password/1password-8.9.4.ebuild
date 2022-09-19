# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="Password manager for families, businesses, and teams."

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://1password.com"
SRC_URI="amd64? ( https://downloads.1password.com/linux/tar/stable/x86_64/${P}.x64.tar.gz -> ${P}.tar.gz )"

LICENSE="1Password"
SLOT="0"
KEYWORDS="~amd64"
IUSE="policykit"

RDEPEND="
	acct-group/onepassword
	dev-libs/nss
	x11-libs/gtk+:3
	x11-misc/xdg-utils
	policykit? ( sys-auth/polkit )
"
DEPEND="${RDEPEND}"

src_unpack() {
	default
	if [ "$ARCH" = "amd64" ]; then
		mv ${WORKDIR}/${P}.x64 ${S}
	fi
}

src_prepare() {
	default

	# The following is adapted from ${S}/after-install.sh
	export POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"
	cat >>"${S}/com.1password.1Password.policy" <<-EOF
	$(cat ${S}/com.1password.1Password.policy.tpl)
	EOF
}

src_install() {
	local targetdir=/opt/1Password

	mkdir -p "${D}${targetdir}"
	cp -R ${S}/* "${D}${targetdir}/" || die "Failed to install application files!"

	mkdir -p "${D}/usr/share"
	cp -R "${S}/resources/icons" "${D}/usr/share/" || die "Failed to install icons!"

	install -Dm0644 "${S}/resources/1password.desktop" -t "${D}/usr/share/applications/" \
		|| die "Failed to install launcher!"

	# Install policy kit file for system unlock
	if use policykit; then
		install -Dm0644 "${S}/com.1password.1Password.policy" -t "${D}/usr/share/polkit-1/actions/" \
				|| die "Failed to install 1Password policy"
	fi

	# Install examples
	dodoc "${S}/resources/custom_allowed_browsers"

	dosym ${targetdir}/${PN} /usr/bin/${PN}
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	# The following is adapted from ${S}/after-install.sh
	local targetdir=/opt/1Password
	local GROUP_NAME="onepassword"
	local HELPER_PATH=${targetdir}/1Password-KeyringHelper
	local BROWSER_SUPPORT_PATH=${targetdir}/1Password-BrowserSupport

	chgrp "${GROUP_NAME}" $HELPER_PATH
	# The binary requires setuid so it may interact with the Kernel keyring facilities
	chmod u+s "$HELPER_PATH"
	chmod g+s "$HELPER_PATH"

	# This gives no extra permissions to the binary. It only hardens it against environmental tampering.
	chgrp "${GROUP_NAME}" $BROWSER_SUPPORT_PATH
	chmod g+s $BROWSER_SUPPORT_PATH

	# chrome-sandbox requires the setuid bit to be specifically set.
	# See https://github.com/electron/electron/issues/17972
	chmod 4755 "${targetdir}/chrome-sandbox"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
