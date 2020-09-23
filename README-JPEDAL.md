# IDRSolutions Ruby Client for JPedal #

Convert PDF to Images with Ruby, using the IDRSolutions Ruby Client to
interact with IDRsolutions' [JPedal Microservice Example](https://github.com/idrsolutions/jpedal-microservice-example).

The JPedal Microservice Example is an open source project that allows you to
convert PDF to Images by running [JPedal](https://www.idrsolutions.com/jpedal/) as an online service.

IDR Solutions offer a free trial service for running JPedal with Ruby,
more information on this can be found [here.](https://www.idrsolutions.com/jpedal/convert-pdf-in-ruby)

-----

# Usage #

## Basic: (Upload) #

```Ruby
require idr_cloud_client
client = IDRCloudClient.new('http://localhost:80/' + IDRCloudClient::JPEDAL)

# Convert the file with the input method specified
results = client.convert(input: IDRCloudClient::UPLOAD, file: 'path/to/file.pdf')

# Return a URL where you can view the converted output.
puts results['downloadUrl']

# Download the converted output to a specified directory:
client.download_result(results, 'path/to/output/dir')
```

## Basic: (Download) #
```Ruby
require idr_cloud_client
client = IDRCloudClient.new('http://localhost:80/' + IDRCloudClient::JPEDAL)

# Convert the file with the input method specified
results = client.convert(input: IDRCloudClient::DOWNLOAD, url: 'http://link.to/filename')

# Return a URL where you can view the converted output.
puts results['downloadUrl']

# Download the converted output to a specified directory:
client.download_result(results, 'path/to/output/dir')
```

The parameters object should contain the parameters that are sent to the API
See the [API](https://github.com/idrsolutions/jpedal-microservice-example/blob/master/API.md) for more details.

See `example_jpedal_usage.rb` for examples.

-----

# Who do I talk to? #

Found a bug, or have a suggestion / improvement? Let us know through the Issues page.

Got questions? You can contact us [here](https://idrsolutions.zendesk.com/hc/en-us/requests/new).

-----

# Code of Conduct #

Short version: Don't be an awful person.

Longer version: Everyone interacting in the JPedal Ruby Client project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

-----

Copyright 2020 IDRsolutions

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.