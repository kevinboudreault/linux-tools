#!/bin/zsh

function dk_ctnr_count(){
        STATUS=${1:="running"}
        echo $(docker ps --filter "status=${STATUS}" --format '{{.ID}}' | wc -l)
}

function dk_status(){
	CONTSTATUS=${1:="running"}
	CONTCOUNT=$(dk_ctnr_count ${CONTSTATUS})

	echo "====[ $CONTSTATUS # $CONTCOUNT ]====\n"
	docker ps --filter "status=${CONTSTATUS}" --format "[{{.ID}}] {{.Names}} : ({{.Status}}) {{.Ports}}"
	echo -e "\n\n"
}

function dk_rld(){
	CTNR_URL=${1:="localhost"}
	CTNR_POR=${2:="9090"}

	curl -X POST ${CTNR_URL}:${CTNR_POR}/-/reload
}

if (curl -s --unix-socket /var/run/docker.sock http/_ping 2>&1 >/dev/null); then
       dk_status "exited"
       dk_status
fi
