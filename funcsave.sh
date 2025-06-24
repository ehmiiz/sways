funcsave () {
	local fn=$1 dir=${ZFUNC:-$HOME/.zsh/functions} 
	[[ -z $fn ]] && {
		echo "usage: funcsave <name>"
		return 1
	}
	command -v "$fn" > /dev/null || {
		echo "no such function: $fn"
		return 1
	}
	mkdir -p "$dir"
	
	# Save the function as a .sh file
	which "$fn" >| "$dir/$fn.sh"
	chmod +x "$dir/$fn.sh"
	
	# Create a symlink with the original function name for easy calling
	ln -sf "$fn.sh" "$dir/$fn"
	
	echo "saved $fn → $dir/$fn.sh (callable as $fn via symlink)"
} 