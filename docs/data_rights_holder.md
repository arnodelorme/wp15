# Data rights holder

The data rights holder is the person or organization responsible for the dataset. They decide under which conditions the dataset can be shared, with whom, and they are responsible for initiating the data transfer to the SIESTA platform.

## Uploading the data by the data rights holder

The data rights holder can use the data transfer mechanism provided by SIESTA to upload the data.

## Downloading the data by the platform owner

The data rights holder can provide instructions and access to the SIESTA product owner to download the data. Besides explaining how the data transfer works, the data rights holder must provide a method to check completeness and integrity of the data after transfer, for example by providing a [manifest file](https://en.wikipedia.org/wiki/Manifest_file) with checksums.

## Information Privacy

### For the raw data (the uploaded ones)

It is the responsability of the data rights holder to ensure that users of the data do not access information posing risk in identifying participants, in particular in the participants.tsv. For instance, if one includes geolocation information, and the user pipeline reads this information, it could be leveraged to re-identify people. We have developed an app that can help checking the information privacy in such file: https://github.com/CPernet/metaprivBIDS.

### For the anonymized data

Users of the platform can use existing pipelines, change them or upload their pipelines and test this works on anonymized data. In short the raw data are changed to prevent direct access to personal data.
- participants.tsv: the data shared in this files are permuted variables wise (ie per column) and one checks the generated/anonymized version does not include any of the original data (ie rows)
- imaging data (to do)
