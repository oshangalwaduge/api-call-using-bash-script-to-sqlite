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
            #object=$(echo $json | jq -r '.bestMatches['$i']')
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
    for (( j=0; j<1; j++ )) #add length2
    do
        symbol=$(jq -r '.bestMatches['$j']."1. symbol"' matches.json)
        echo $j
        echo $symbol

        curl -s $URL2$symbol | jq '.' > daily.json

        information=$(jq -r '."Meta Data"."1. Information"' daily.json)
        sym=$(jq -r '."Meta Data"."2. Symbol"' daily.json)
        last_refreshed=$(jq -r '."Meta Data"."3. Last Refreshed"' daily.json)
        output_size=$(jq -r '."Meta Data"."4. Output Size"' daily.json)
        time_zone=$(jq -r '."Meta Data"."5. Time Zone"' daily.json)

        # INSERT="INSERT INTO 'Meta Data' (Information,Symbol,'Last Refreshed','Output Size','Time Zone') VALUES ('$information','$sym','$last_refreshed','$output_size','$time_zone');"
        # sqlite3 assignment.db "$INSERT"
        # echo "$INSERT"   

        length3=$(jq -r '."Time Series (Daily)" | length' daily.json)    
        #echo $length3
        for (( k=2; k<102; k++ ))
        do
            dby=$(date -d '-'$k' day' '+%Y-%m-%d')
            dow=$(date -d $dby +"%u")
            if (($dow >= 2 && 5 >= $dow))
            # echo $dby
        done

        # dby=$(date -d '-2 day' '+%Y-%m-%d')
        # echo $dby
        # lddetails=$(jq -c '."Time Series (Daily)"."2020-08-14"' daily.json)
        # echo $lddetails


        #sleep 15
        #echo "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$API_KEY"
    done

}


#### MAIN SCRIPT ####
getCompanyData $URL
saveDailyData
#echo $length
