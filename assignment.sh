#!/bin/bash

#Declaring global variables

#Search Company API
API_KEY="L5FZEL2MI5T557F4"
KEYWORD="AB"
URL="https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=$KEYWORD&apikey=$API_KEY"

URL2="https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&apikey=$API_KEY&symbol="

checking_value=0.5
filtered=()


# echo $URL

getCompanyData() {
    # curl -s $1 | jq . 
    json=$(curl -s $1)
    length=$(echo $json | jq -r '.[] | length')
    
    for (( i=0; i<$length; i++ ))
    do
        match_score=$(echo $json | jq -r '.bestMatches['$i']."9. matchScore"')
        
        if [ $(echo "$match_score>$checking_value" | bc) -ne 0 ]; then
            #echo "Higher"
            filtered=$(echo $json | jq -r '.bestMatches['$i']')
            all+=$(echo $filtered"," )   
        else
            echo "Lower"
        fi
    done
    echo '{"bestMatches": ['$all']}' | perl -pe 's/.*\K,/ /' > matches.json

    #jq -r '.bestMatches[]."9. matchScore"'

}

saveDailyData() {
    length2=$(jq '.[] | length' matches.json)
    #echo $length2
    for (( j=0; j<$length2; j++ )) #add length2
    do
        symbol=$(jq -r '.bestMatches['$j']."1. symbol"' matches.json)
        #echo $j
        #echo $symbol

        curl -s $URL2$symbol | jq '.' > daily.json

        information=$(jq -r '."Meta Data"."1. Information"' daily.json)
        sym=$(jq -r '."Meta Data"."2. Symbol"' daily.json)
        last_refreshed=$(jq -r '."Meta Data"."3. Last Refreshed"' daily.json)
        output_size=$(jq -r '."Meta Data"."4. Output Size"' daily.json)
        time_zone=$(jq -r '."Meta Data"."5. Time Zone"' daily.json)

        echo "Meta Data"
        echo "Information: $information | Symbol: $sym | Last Refreshed: $last_refreshed | Output Size: $output_size | Time Zone: $time_zone"

        # INSERT="INSERT INTO 'Meta Data' (Information,Symbol,'Last Refreshed','Output Size','Time Zone') VALUES ('$information','$sym','$last_refreshed','$output_size','$time_zone');"
        # sqlite3 assignment.db "$INSERT"
        # echo "$INSERT"   

        #length3=$(jq -r '."Time Series (Daily)" | length' daily.json)    
        #echo $length3
        k=2
        w=1

        while [ $k -le 200 ]
        do
            days=$(date -d '-'$k' day' '+%Y-%m-%d')
            dow=$(date -d $days +"%u")
            # echo $k
            # echo $days
            # echo $dow
            if [[ $dow -ge 2 ]] && [[ 5 -ge $dow ]]
            then
                #echo "Working Day $days - $dow"
                while [ $w -le 2 ] #add 100
                do
                    # echo $days
                    dayresult=$(echo $(jq -r -c '."Time Series (Daily)"."'$days'"' daily.json))
                    if [[ $dayresult != null ]]
                    then
                        # echo $days
                        # echo $dayresult

                        open=$(jq -r -c '."Time Series (Daily)"."'$days'"."1. open"' daily.json)
                        high=$(jq -r -c '."Time Series (Daily)"."'$days'"."2. high"' daily.json)
                        low=$(jq -r -c '."Time Series (Daily)"."'$days'"."3. low"' daily.json)
                        close=$(jq -r -c '."Time Series (Daily)"."'$days'"."4. close"' daily.json)
                        volume=$(jq -r -c '."Time Series (Daily)"."'$days'"."5. volume"' daily.json)
                        # echo $open $high $low $close $volume

                        echo "Time Series (Daily)"
                        echo "Day: $days | Opening Price: $open | High Price: $high | Low Price: $low | Close Price: $close | Volume: $volume"

                        # INSERT2="INSERT INTO 'Time Series (Daily)' (Day,Open,High,Low,Close,Volume) VALUES ('$days','$open','$high','$low','$close','$volume');"
                        # sqlite3 assignment.db "$INSERT2"
                        # echo "$INSERT2"  

                    fi
                    ((w++))
                    break
                done
            fi
            ((k++))  
        done
        sleep 15
    done

}


#### MAIN SCRIPT ####
getCompanyData $URL
saveDailyData
