# Address Verification demo using the batch functions

In this folder there are two Ruby scripts that demonstrate how to use the 
address verification functions for New Zealand and Australia. These functions
seek to process a CSV file of sample addresses, and generate a CSV stream on
standard output. 

## Usage instructions

``` 
bundle exec ruby process_nz_address_csv.rb <input-file.csv>
```

or 

``` 
bundle exec ruby process_au_address_csv.rb <input-file.csv>
```

We have provided two sample CSV files for demonstration purposes. The files contain a
selection of various addresses for each country.  

You will also need to set the following environment variables:

- `AF_KEY` - your API key for accessing the Addressfinder API
- `AF_SECRET` - the API secret corresponding to your API key

You can obtain an API key by registering for a free trial account at https://addressfinder.com/

## Example execution

> `export AF_KEY=XXXXXXXXXXXXXXX`
> `bundle exec ruby process_nz_address_csv.rb sample_addresses_nz.csv`

```
address_id,address_query,address_query_length,full_address,address_id
1,133 wilton road wilton wellington,33,"133 Wilton Road, Wilton, Wellington 6012",2-.F.1W.v.Torm
2,1 ghuznee st te aro wellington 6011,35,"1 Ghuznee Street, Te Aro, Wellington 6011",2-2eNwG1oBJExni2nUFJm1cW
3,40 severne st springlands blemnheim,35,"40 Severne Street, Yelverton, Blenheim 7201",2-.7.7.E.4$2
4,hahaha,6,"",""
5,"14 Espin Crescent, Karori, Wellington 6012",42,"14 Espin Crescent, Karori, Wellington 6012",2-.F.1W.J.tx4
6,"Level 7, 45 Johnston Street, Wellington Central, Wellington 6011",64,"Level 7, 45 Johnston Street, Wellington Central, Wellington 6011",3-.2u
# ...
```

> `bundle exec ruby process_au_address_csv.rb sample_addresses_au.csv`

```
address_id,address_query,address_query_length,full_address,address_id
1,"10/274 harbour drive, coffs harbour NSW 2450",44,"Unit 10, 274 Harbour Drive, COFFS HARBOUR NSW 2450",670cd8c3-b883-ee24-2874-74440e515b80
2,"9/274 harbour drive, coffs harbour NSW 2450",43,"Unit 9, 274 Harbour Drive, COFFS HARBOUR NSW 2450",42ae5625-d679-266b-5d66-5ece6bbfb179
3,"8/274 harbour drive, coffs harbour NSW 2450",43,"Unit 8, 274 Harbour Drive, COFFS HARBOUR NSW 2450",447a0952-c354-80de-712f-e3458f71bf1a
4,hahaha,6,"",""
5,"Unit 56, Level C, 12 Limburg Way, GREENWAY ACT 2900",51,"Unit 56, Level C, 12 Limburg Way, GREENWAY ACT 2900",275aa5ff-401e-3cd8-9de9-e9c36eb262cb
# ...
```

## Code example

Take close look at the function `process_csv` which manages the reading of the CSV file and the creation of
each block. In the example, fairly small block sizes are used, but you will likely want to use a larger size
of around 100 records. 

The `process_block` function is responsible for making the API call and processing the response. The response
is used to compose each CSV line, which is written to `$stdout`.
