_dom_listing() {
	local cur opts

	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	if [ $COMP_CWORD -eq 1 ]; then
		if [ $1 == domssh ]; then
			# only give running VMs as options
			opts=$(virsh list --name)
		elif [ $1 == domstart ]; then
			# only give turned off VMs as options
			opts=$(virsh list --inactive --name)
		else
			opts=$(virsh list --all --name)
		fi
	# domnuke can operate on multiple VMs
	elif [ $1 == domnuke ]; then
		opts=$(virsh list --all --name)
	else
		return 0
	fi

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _dom_listing domnuke
complete -F _dom_listing domssh
complete -F _dom_listing domstart
