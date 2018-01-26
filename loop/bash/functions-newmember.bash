#!/usr/bin/env bash
# no need sha-bang for the script to run,
# but needed, so file manager can detect its type.

### -- function -- 

function parse_update() {

    updates=$(curl -s "${tele_url}/getUpdates?offset=$last_id")
    # echo $updates | json_reformat

    count_update=$(echo $updates | jq -r ".result | length") 
    # echo $count_update
    
    [[ $count_update -eq 0 ]] && echo -n "."

    for ((i=0; i<$count_update; i++)); do
        update=$(echo $updates | jq -r ".result[$i]")
        # echo "$update"
    
        last_id=$(echo $update | jq -r ".update_id") 
        # echo "$last_id"
     
        message_id=$(echo $update | jq -r ".message.message_id") 
        # echo "$message_id"

        chat_id=$(echo $update | jq -r ".message.chat.id") 
        # echo "$chat_id"

        get_feedback "$update"
        
        if [ -n "$update_with_new_member" ];
        then
            echo -e "\n: ${feedback}"

            result=$(curl -s "${tele_url}/sendMessage" \
                      --data-urlencode "chat_id=${chat_id}" \
                      --data-urlencode "text=$feedback"
                );
            # echo $result | json_reformat
        fi

        last_id=$(($last_id + 1))            
        echo $last_id > $last_id_file
    done
}

function get_feedback() {
    local update=$1

    update_with_new_member=$(echo $update | jq -r ".message | select(.new_chat_member != null)")
    if [ -n "$update_with_new_member" ];
    then
        # echo "${update_with_new_member}"
        
        new_chat_member=$(echo $update | jq -r ".message.new_chat_member")
        # echo "$new_chat_member"
        
        first_name=$(echo $new_chat_member | jq -r ".first_name")
        last_name=$(echo $new_chat_member | jq -r ".last_name")
        username=$(echo $new_chat_member | jq -r ".username")
        
        # "😊"
        feedback="Selamat datang di @dotfiles_id 😊, $first_name $last_name @${username}."
    else
        feedback=""
    fi
}

