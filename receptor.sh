#!/bin/bash 

declare -g REQUEST=''

read -r buffer
REQUEST+="${buffer%%$'\r'}"

while read -r BUFFER; do
	# reached the end of the headers, break.
	[[ "${BUFFER%%$'\r'}" ]] || break
	REQUEST+="
${BUFFER%%$'\r'}"
done

echo "${REQUEST}" > start
echo "$(< retorno)"
exit 0
