#!/bin/zsh

echo "Hostname: $(hostname)"
echo "Time:     $(date)"

#HD check
function checkHDSpace(){
	#HD space left
	echo "==={ HD }===\n"
	df -h | grep /dev
	echo -e "\n\n"
}

checkHDSpace
