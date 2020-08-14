# /bin/bash
curl -s "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=AB&apikey=L5FZEL2MI5T557F4" | jq . > searchcompany.json

echo "created searchcompany.json"

l=$(jq '.[] | length' searchcompany.json)
echo $l

for (( i=0; i<1; i++ ))
do
        match_score=$(jq '.bestMatches['$i']."9. matchScore" | tonumber' searchcompany.json)
        checking_value=0.5

        if [ $(echo "$match_score>$checking_value" | bc) -ne 0 ];then
                echo "Higher than $checking_value = $match_score"
                symbol=$(jq -r '.bestMatches['$i']."1. symbol"' searchcompany.json)
                echo "$symbol"
                #curl -s "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=L5FZEL2MI5T557F4" | jq '."Meta Data"','."Time Series (Daily)"."2020-08-13"'
                curl -s "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=L5FZEL2MI5T557F4" | jq '[.[]] | .[0]','.[1]."2020-08-13"'



        else
                echo "Lower than $checking_value = $match_score"
        fi
done
