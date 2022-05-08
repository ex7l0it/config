#!/bin/bash
proxy_protocol="socks5"
proxy_port="7890"
function confirm
{
	while true
	do
	    read -r -p "[Y/n] " input
	    case $input in
	        [yY][eE][sS]|[yY])
	            return 1
	            ;;
	        [nN][oO]|[nN])
	            return 0
	            ;;
	        *)
	            echo "Invalid input..."
	            ;;
	    esac
	done
}
function change_apt_source
{
	# change apt source list -- ubuntu 20.04 LTS
	mirror_url=mirrors.aliyun.com && \
	sudo sed -i "s/security.ubuntu.com/$mirror_url/" /etc/apt/sources.list
	sudo sed -i "s/cn.archive.ubuntu.com/$mirror_url/" /etc/apt/sources.list 
	sudo sed -i "s/security-cdn.ubuntu.com/$mirror_url/" /etc/apt/sources.list
	sudo apt update
}

function install_basic_software
{
	# install vmtools
	sudo apt install -y open-vm-tools open-vm-tools-desktop
	# install some software
	sudo apt install -y ssh vim net-tools gdb git zsh tmux lrzsz proxychains curl ruby ncat \
	make cmake gcc g++ python3-pip ipython3 patchelf binutils build-essential qemu
	# install some libs
	sudo apt install -y lib32ncurses5-dev lib32z1 lib32z1-dev libssl-dev ruby-dev
	sudo apt install -y flex libncurses5-dev bison libssl-dev libelf-dev
	
}

function install_modules
{
	# upgrade pip
	pip3 install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple 
	pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
	# install pwntools ropper
	pip3 install pwntools ropper trzsz -i https://pypi.tuna.tsinghua.edu.cn/simple 
}

function proxy_setting
{
	# get the host's ip address
	gateway=`ip addr | grep inet | grep ens | tr -s " " | cut -d " " -f3 | sed -r "s/(.{1,3}\..{1,3}\..{1,3}\.).{1,3}\/.{1,2}/\11/"`
	echo "[*] Default proxy setting is: $gateway:$proxy_port"
	confirm
	if [ $? -eq 1 ]; then
		# configure git proxy
		git config --global http.proxy "$proxy_protocol://$gateway:$proxy_port"
		git config --global https.proxy "$proxy_protocol://$gateway:$proxy_port"
		# configure proxychains 
		sudo sed -i "s/^socks4\ \t127.0.0.1\ 9050/$proxy_protocol\ $gateway\ $proxy_port/" /etc/proxychains.conf
		proxy="proxychains"
		echo "[*] Proxy is enabled: $proxy_protocol://$gateway:$proxy_port"
	else 
		echo "[*] Proxy is disabled"
	fi
}

function install_pwntools
{
	echo -e "\n\n[*] Installing pwntools...\n\n"
	python3 -c "import pwn" 2>/dev/null
	if [ $? -ne 0 ]; then
		## install pwntools
		$proxy git clone https://github.com/pwndbg/pwndbg
		cd pwndbg && ./setup.sh
		cd ..
	else
		echo "[*] pwntools is installed. skipped"
	fi
}

function install_gem_soft
{
	echo -e "\n\n[*] Installing one_gadget and seccomp-tools...\n\n"
	## instal one_gadget and seccomp-tools
	sudo gem install one_gadget
	sudo gem install seccomp-tools
}

function install_r2 
{
	echo -e "\n\n[*] Installing radare2...\n\n"
	# install r2
	r2 -v 2>/dev/null 
	if [ $? -ne 0 ]; then
		$proxy git clone https://github.com/radareorg/radare2
		bash radare2/sys/install.sh
	else
		echo "[*] r2 is installed. skipped"
	fi
}

function install_gef 
{
	# root install gef
	$proxy wget http://gef.blah.cat/sh -O gef.sh
	if [ $? -eq 0 ]; then
		sudo $proxy bash gef.sh
		# edit root's .gdbinit
		res=`sudo cat ~/.gdbinit | grep "set auto-load safe-path" | wc -l`
		if [ $res -eq 0 ]; then 
			echo -e "set auto-load safe-path / \nset architecture i386:x86-64" | sudo tee -a /root/.gdbinit
		fi
	fi
}

function download_glibc
{
	echo -e "\n\n[*] Downloading glibc-all-in-one...\n\n"
	# glibc-all-in-one
	sudo mkdir /opt/glibc-all-in-one
	if [ $? -eq 0 ]; then
		sudo chown $USER.$USER /opt/glibc-all-in-one
		$proxy git clone https://github.com/matrix1001/glibc-all-in-one /opt/glibc-all-in-one
		if [ $? -eq 0 ]; then
			cd /opt/glibc-all-in-one
			./download 2.23-0ubuntu11.3_i386
			./download 2.23-0ubuntu11.3_amd64
			./download 2.27-3ubuntu1_i386
			./download 2.27-3ubuntu1_amd64

			# patchelf configure
			res=`cat ~/.zshrc | grep "patchelf" | wc -l`
			if [ $res -eq 0 ]; then 
echo -e "\n# patchelf\n\
alias p32_u16='patchelf --set-interpreter /opt/glibc-all-in-one/libs/2.23-0ubuntu11.3_i386/ld-2.23.so --set-rpath /opt/glibc-all-in-one/libs/2.23-0ubuntu11.3_i386'\n\
alias p64_u16='patchelf --set-interpreter /opt/glibc-all-in-one/libs/2.23-0ubuntu11.3_amd64/ld-2.23.so --set-rpath /opt/glibc-all-in-one/libs/2.23-0ubuntu11.3_amd64'\n\
alias p32_u18='patchelf --set-interpreter /opt/glibc-all-in-one/libs/2.27-3ubuntu1_i386/ld-2.27.so --set-rpath /opt/glibc-all-in-one/libs/2.27-3ubuntu1_i386'\n\
alias p64_u18='patchelf --set-interpreter /opt/glibc-all-in-one/libs/2.27-3ubuntu1_amd64/ld-2.27.so --set-rpath /opt/glibc-all-in-one/libs/2.27-3ubuntu1_amd64'\n\
alias p64-ld23='patchelf --set-interpreter /opt/glibc-all-in-one/libs/2.23-0ubuntu11.3_amd64/ld-2.23.so --replace-needed libc.so.6'\n\
alias p64-ld27='patchelf --set-interpreter /opt/glibc-all-in-one/libs/2.27-3ubuntu1_amd64/ld-2.27.so --replace-needed libc.so.6'" >> ~/.zshrc
			fi
		fi
	fi
}

function install_libcsearcher
{
	# LibcSearcher
	$proxy git clone https://github.com/rycbar77/LibcSearcher.git ~/.local/lib/python3.8/site-packages/LibcSearcher
	if [ $? -eq 0 ]; then 
		cd ~/.local/lib/python3.8/site-packages/LibcSearcher
		python3 setup.py develop
		rmdir libc-database
		ln -s /mnt/hgfs/ctf/libc-database libc-database
		cd ~/Downloads
	fi 
}

function install_vimplus
{
	## install vimplus
	$proxy git clone https://github.com/chxuan/vimplus.git ~/.vimplus
	cd ~/.vimplus
	$proxy ./install.sh
	cd ~/.vim/plugged/YouCompleteMe
	python3 ./install.py
	cd ~/Downloads


	## edit .vimrc
	sed -i "s/nnoremap\ Y\ :CopyText/\"\ nnoremap\ Y\ :CopyText/" ~/.vimplus/.vimrc
	sed -i "s/nnoremap\ D\ :DeleteText/\"\ nnoremap\ D\ :DeleteText/" ~/.vimplus/.vimrc
	sed -i "s/nnoremap\ C\ :ChangeText/\"\ nnoremap\ C\ :ChangeText/" ~/.vimplus/.vimrc
	$proxy wget https://raw.githubusercontent.com/zzZ200/config/main/.vimrc.custom.config -O ~/.vimrc.custom.config
	$proxy wget https://raw.githubusercontent.com/zzZ200/config/main/.vimrc.custom.plugins -O ~/.vimrc.custom.plugins
	mkdir ~/.vim/UltiSnips/
	$proxy wget https://raw.githubusercontent.com/zzZ200/config/main/python.snippets -O ~/.vim/UltiSnips/python.snippets

}

function install_ohmyzsh
{
	## install oh-my-zsh + zsh-autosuggestions + powerlevel10k
	$proxy wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O ohmyzsh.sh
	if [ $? -eq 0 ]; then
		$proxy bash ohmyzsh.sh
		$proxy git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		sed -i "s/plugins=(git)/plugins=(git\ zsh-autosuggestions)/" ~/.zshrc
		res=`cat ~/.zshrc | grep "# local bin" | wc -l`
		if [ $res -eq 0 ]; then 
			echo -e '\n# local bin\nexport PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
		fi
		mkdir ~/.fonts
		if [ $? -eq 0 ]; then
			cd ~/.fonts
			$proxy wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
			$proxy wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
			$proxy wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
			$proxy wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
		fi
		read -s -n1 -p "[*] Please edit the terminal profile to set the fonts to 'MesloLGS NF Regular'... "

		$proxy git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
		sed -r -i "s/ZSH_THEME=.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc
	fi
	cd ~/Downloads
}

function self_setting
{
	# aslr
	res=`cat ~/.zshrc | grep "# User's alias" | wc -l`
	if [ $res -eq 0 ]; then 
echo -e "\n# User's alias\n\
alias offaslr='sudo sysctl -w kernel.randomize_va_space=0' \ 
alias onaslr='sudo sysctl -w kernel.randomize_va_space=2' \
alias syscall64='cat /usr/include/x86_64-linux-gnu/asm/unistd_64.h | grep ' \
alias syscall32='cat /usr/include/x86_64-linux-gnu/asm/unistd_32.h | grep '" >> ~/.zshrc
	fi
	# sudo nopasswd
	res=`sudo cat /etc/sudoers | grep "$USER ALL=(ALL:ALL) NOPASSWD:ALL" | wc -l`
	if [ $res -eq 0 ]; then
	echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
	fi
}

cd ~/Downloads
ln -s /mnt/hgfs ~/Desktop

change_apt_source
install_basic_software
install_modules
proxy_setting
install_pwntools
install_gem_soft
install_r2
install_gef
download_glibc
install_libcsearcher
echo "[*] If you want to continue to install vimplus and ohmyzsh?[Y/n]"
confirm
if [ $? -eq 1 ]; then
	install_vimplus
	install_ohmyzsh
fi
self_setting

echo "[*] Finished! Please logout and login again"
