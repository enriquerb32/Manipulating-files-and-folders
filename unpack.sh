#!/bin/bash

# For decomprssing files for 4 options: unzip, gunzip, bunzip, uncompress

## We initialise each variable
recursivity=false
verbosity=false
decomp_counter=0
non_decomp_counter=0
cin=
cin_length=


## We define each function

# Receives a file or directory and run a case statement to check for the correct method to apply
unpacking(){

    local fileName="$1"
    local fileType=`file -b "$fileName"`
    case "$fileType" in

        ## If they match, the decompressing method will be passed as an argument $1 and the filename as $2 to case hanlder function

        gzip*) decompress_result "gunzip -f -k" "$fileName" ;;

        bzip2*) decompress_result "bunzip2 -f -k" "$fileName" ;;

        Zip*) decompress_result "unzip -o -q" "$fileName"  ;;

        compress"'"d*) if [[ ! "$fileName" = *.gz ]] ; then mv "$fileName" "$fileName.gz" ; fi

            decompress_result "gunzip -f -k" "$fileName"  ;;

        directory) directory_matcher unpacking ;;

        *) decompress_no "$fileName" ;;

    esac

}

# Performs matching case
decompress_result() {

    if $1 "$2" ; then decompress_yes "$2" ; else  echo "$2 decompressinged failed" ; fi

}

# Shows details when matching method and success decompressing
decompress_yes() {

   let decomp_counter++

    if $verbosity ; then echo "unpackinging $1 ..." ; fi

}

# Shows details when no method matches
decompress_no() {

    let non_decomp_counter++

    if $verbosity ; then echo "ignoring $1"; fi

}

# Shows directory match
directory_matcher(){

    if $recursivity ; then

        while IFS= read -r -d '' FILE; do "$1" "$FILE"
        done < <(find . -mindepth 2 -type f -name '*' -print0)

    else

        while IFS= read -r -d '' FILE; do "$1" "$FILE"
        done < <(find . -mindepth 2 -maxdepth 2 -type f -name '*' -print0)

    fi
}

## Main function
# Create the array from user input and check for transpositions regardless of the position
# Loop finishes when all parameters are used
while [ "$1" != "" ]; do

    cin=("${cin[@]}" "$1")

    if [[ "$1" =~ ^-r$ ]]; then recursivity=true; fi

    if [[ "$1" =~ ^-v$ ]]; then verbosity=true; fi

    shift

done

cin_length=${#cin[@]}

for (( i=1 ; i < $cin_length ; i++)); do

    if [[ -f ${cin[i]} || -d  ${cin[i]} ]]; then

        unpacking "${cin[i]}"

    elif [[ ! "${cin[i]}" =~ -v|-r ]]; then

         echo  "${cin[i]} - file/directory does not exist"

    fi

done

echo "decompressed $decomp_counter archives(s)"

exit $non_decomp_counter
