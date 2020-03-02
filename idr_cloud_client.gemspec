lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'idr_cloud_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'idr_cloud_client'
  spec.version       = IDRCloudClient::VERSION
  spec.authors       = ['IDRsolutions']
  spec.email         = ['support@idrsolutions.zendesk.com']
  spec.date          = Time.now.strftime('%Y-%m-%d')

  spec.summary       = 'Ruby API for IDRSolutions Microservices'
  spec.description   = "Convert PDF to HTML5, SVG, or image with Ruby, using the IDR Cloud Client to interact with
                        IDRsolutions' BuildVu Microservice Example. The Microservice Example is an open source
                        project that allows you to convert PDF to HTML5, SVG, or image by running BuildVu or JPedal as a web service in the cloud or on-premise. For documentation and usage examples, check out our GitHub page. "
  spec.homepage      = 'https://github.com/idrsolutions/idrsolutions-ruby-client'
  spec.license       = 'Apache-2.0'

  spec.required_ruby_version = '>= 2.3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.17'
  spec.add_runtime_dependency 'json', '~> 2.1', '>= 2.1'
end
