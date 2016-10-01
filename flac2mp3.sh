##!/bin/bash

#
# Trap ctrl-c and call ctrl_c()
#
trap ctrl_c INT

function ctrl_c() {
    echo -e "\nExiting ..."
    exit 1
}

#
# Read options
#
output_dir="`pwd`"
recurse="false"

while getopts 'hrd:' flag; do
    case "${flag}" in
        h)
            echo "Usage: ./flac2mp3 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "    -h                 Print this help text and exit"
            echo "    -r                 Convert files recursively"
            echo "    -d OUTPUT_DIR      Specify output directory"
            exit 0
            ;;
        d) output_dir="${OPTARG}" ;;
        r) recurse="true" ;;
        *) error "Unexpected option ${flag}" ;;
    esac
done

#
# Start converting files
#
echo "Start writing to ${output_dir} ..."

if [ "$recurse" = "false" ]
then

    mkdir -p "$output_dir"
    for track in *; do
        extension="${track##*.}"
        case "${extension}" in
            flac|m4a|opus)
                output="${output_dir}/${track[@]/%${extension}/mp3}"
                echo "Converting ${track} to ${output} ..."
                ffmpeg -n -loglevel warning -i "${track}" -vn -acodec libmp3lame -b:a 320k -qscale:a 0 "${output}"
                ;;
            mp3)
                cp -n "${track}" "${output_dir}"
                ;;
            *)
                echo -e "\e[33mNot converting ${track} (cause: bad or unspecified file extension)\e[0m"
                ;;
        esac
    done

elif [ "$recurse" = "true" ]
then

    for album in */; do
        echo -n "Converting ${album} to ${output_dir} "
        mkdir -p "${output_dir}/${album}"

        for track in "$album"*; do
            extension="${track##*.}"
            case "${extension}" in
                flac|m4a|opus)
                    output="${output_dir}/${track[@]/%${extension}/mp3}"
                    ffmpeg -n -loglevel warning -i "${track}" -vn -acodec libmp3lame -b:a 320k -qscale:a 0 "${output}"
                    ;;
                mp3)
                    cp -n "${track}" "${output_dir}/${album}"
                    ;;
                *)
                    echo -e "\e[33mNot converting ${track} (cause: bad or unspecified file extension)\e[0m"
                    ;;
            esac
            echo -n "."
        done
        echo ""
    done

fi

exit 0
