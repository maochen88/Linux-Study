#!/bin/bash
yum install -y git
user=`id | awk -F'[()]' '{print $2}'`
[ "$user" != "root" ] && \
echo "Please login root user to execute this shell script." && exit 1
usage() {
	echo "Note: Git install shell script."
	echo "Usage: $0 [ options ]"
	echo "Options:"
	echo " <tag> : pleae use \"git tag\" to view git version"
	echo
	exit 0
}
[ $# == 0 ] && usage
while [ $# -gt 0 ]
do
	case "$1" in
	-h | --help)
		usage;;
	*)
		break;;
	esac
	shift
done
echo "------"
echo "Clone git DIR : ./git"
git clone git://git.kernel.org/pub/scm/git/git.git git
cd git
echo "Step 1: Backup Shell Script ..."
echo "------"
echo "Backup DIR : /tmp/"
cp -af ./git-update.sh /tmp/
echo ; sleep 3
# Solve following errors:
# http-push.c:17:19: warning: expat.h: No such file or directory ( expat-devel )
echo "Step 2: Yum updating ..."
echo "------"
yum -y install curl-devel expat-devel gettext-devel openssl-devel \
zlib-devel perl-ExtUtils-Embed expat-devel
echo ; sleep 3
version=$1
echo "Step 3: Begin install Git $version"
echo "------" ; sleep 3
git tag | grep -q $version
[ $? -gt 0 ] && echo "Warning: git $version is non-existent." && \
cp -af /tmp/git-update.sh ./ && exit 1
for version in $version
do
	git reset --hard
	git clean -fdx
	git checkout $version ||{
		echo "Checkout git $version failed."; exit 1
	}
	make prefix=/usr/local all && \
	make prefix=/usr/local install || {
		echo "Install git $version failed."; exit 1
	}
	echo "------"
	echo "Installed Git $version."
done
echo ; sleep 3
echo "Step 4: Fix Git command completion"
cp -af contrib/completion/git-completion.bash /etc/bash_completion.d/
chown root:root /etc/bash_completion.d/git-completion.bash
source /etc/bash_completion.d/git-completion.bash
rm -rf /etc/profile.d/git.sh
cat >>/etc/profile.d/git.sh<<-EOF
#!/bin/bash
if [ -f /etc/bash_completion.d/git-completion.bash ]
then
source /etc/bash_completion.d/git-completion.bash
fi
EOF
echo "Step 5: Restore Shell script ..."
echo "------"
echo "Source DIR : /tmp/"
cp -af /tmp/git-update.sh ./
echo
yum remove git -y &> /dev/null
source /etc/profile.d/git.sh
source /etc/profile.d/git.sh
echo "------------------"
git --version
echo "------------------"
