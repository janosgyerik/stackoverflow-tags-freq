### Icons

Complete list of supported icons:

http://fontawesome.io/icons/

Documentation:

https://rstudio.github.io/shinydashboard/appearance.html#icons

### Using a proper API key

You can verify your current quota with:

    curl "https://api.stackexchange.com/2.2/questions?site=stackoverflow&key=$key" | zcat | jq '.quota_max, .quota_remaining'

After you define `key` to the proper API key, you should see different values.
(x out of 10000 instead of 300)
