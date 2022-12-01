# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info linux-mod git-r3

DESCRIPTION="REALTEK RTL88x2B USB Linux Driver"
HOMEPAGE="https://github.com/RinCat/RTL88x2BU-Linux-Driver"
EGIT_REPO_URI="https://github.com/RinCat/RTL88x2BU-Linux-Driver.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64"

BUILD_TARGETS="clean modules"
MODULE_NAMES="88x2bu(kernel/drivers/net/wireless)"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KSRC=/lib/modules/${KV_FULL}/build"
}
