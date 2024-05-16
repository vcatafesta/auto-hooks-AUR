#!/usr/bin/env bash

# webhooks() {
# curl -X POST -H "Accept: application/json" -H "Authorization: token $CHAVE" --data '{"event_type": "clone"}' https://api.github.com/repos/BigLinuxAur/$package/dispatches
# }

sendWebHooks() {
echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
echo " AUR ""$pkgname"="$veraur"
echo "Repo ""$pkgname"="$verrepo"
package=$pkgname
sleep 10
webhooks
}

repo=BigLinuxAur
sed -i 's/#.*$//' lista-auto-hooks-${repo}
sed -i '/^$/d' lista-auto-hooks-${repo}

for pkgname in $(cat lista-auto-hooks-${repo}); do
  if [ -z "$(echo $i)" -o -z "$(echo $i | grep \#)" ];then
    #versão do repositorio BigLinux
    verrepo=
    verrepo=$(pacman -Ss $pkgname | grep biglinux-${repo} | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d "/" -f2 | grep -w $pkgname | cut -d " " -f2 | cut -d ":" -f2)

    sleep 1

    #versão do AUR
    #limpa todos os $
    veraur=
    pkgver=
    pkgrel=

    git clone https://aur.archlinux.org/${i}.git
    chmod 777 -R $i
    pushd $i

    if [ -z "$(grep -q 'pkgver()' PKGBUILD)" ];then
      source PKGBUILD
      veraur=$pkgver-$pkgrel
      veraur=${veraur//[.-]}
    else
      sudo -u builduser bash -c 'makepkg -so --noconfirm --skippgpcheck --needed'
      sleep 5
      source PKGBUILD
      veraur=$pkgver-$pkgrel
    fi
    #apagar diretorio do git
    rm -r $pkgname

    # se contiver apenas numeros ou se for com hash
    if [[ $veraur =~ ^[0-9]+$ ]]; then
      if [ "$veraur" -gt "$verrepo" ]; then
        sendWebHooks
      else
        echo "Versão do $pkgname é igual !"
        sleep 1
      fi
    else
      if [ "$veraur" != "$verrepo" ]; then
        sendWebHooks
      else
        echo "Versão do $pkgname é igual !"
        sleep 1
      fi
    fi




