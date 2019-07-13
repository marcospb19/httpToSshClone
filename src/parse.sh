# parse.sh

# Only receives one string variable starting with a hyphen
# representing a flag (Example: --help or -h)
function parse_flags()
{
	local input="$1"

	if [[ "${input:1:1}" == "-" ]]; then
		# If second character is also a hyphen
		# Example: --help

		local arg="${input:2}"

		case "$arg" in

			help)    show_help    ; exit 0 ;;
			version) show_version ; exit 0 ;;

			recursive) recursive="true" ;;
			verbose)   verbose="true"   ;;
			http*)     http="true"      ;;
			ssh)       ssh="true"       ;;

			*) echo "Option '--$arg' not recognized, see gloner --help."
				exit 1 ;;
		esac
	else
		# Only first character is a hyphen
		# Example -h
		local size="${#1}"
		local arg=""

		# For each letter after the hyphen, process the flags
		# Example: "-hv", process flags 'h' and 'v'
		for (( i = 1 ; i < $size ; i++ )); do
			arg="${input:$i:1}"

			case "$arg" in
				h) show_help    ; exit 0 ;;
				V) show_version ; exit 0 ;;

				R) recursive="true" ;;
				v) verbose="true"   ;;

				*) echo "Unknown option '-$arg', see gloner --help."
					exit 1 ;;
			esac

		done
	fi
}

# Receives all arguments passed to gloner and filter flags
# Returns $arguments and $number_of_arguments
function parse_arguments()
{
	arguments=()

	for i in "$@"; do
		# Check if first character is a hyphen
		if [[ "${i:0:1}" == "-" ]]; then
			parse_flags "$i"
		else
			arguments+=("$i")
		fi
	done

	number_of_arguments="${#arguments[@]}"

	# If no command is given
	if [[ "$number_of_arguments" == 0 ]]; then
		echo "No command given."
		show_help
		exit 1
	fi
}

# Checks if array of arguments are valid
# directories, if one of them isn't, exit
function check_directories()
{
	exit=""

	for i in "$@"; do
		# If isn't a directory
		if [[ ! -d "$i" ]]; then
			exit="true"
			echoerr "'$i' is not a directory"

		fi
	done

	# Note that this function lists every fail before exiting
	if [[ "$exit" == "true" ]]; then
		exit 1
	fi
}

# Similar to check_directories
#
# Checks if array of arguments are valid git
# directories, if one of them isn't, exit
function check_git_directories()
{
	exit=""

	for i in "$@"; do
		# If isn't a directory
		if [[ ! -d "$i" ]]; then
			exit="true"
			echoerr "'$(realpath "$i")' is not a directory"

		# If isn't a git directory
		elif [[ ! -d "$i"/.git ]]; then
			exit="true"
			echoerr "\"$(realpath "$i")\" is not a git directory"
		fi
	done

	# Note that this function lists every fail before exiting
	if [[ "$exit" == "true" ]]; then
		exit 1
	fi
}
