# encoding: utf-8

Gem::Specification.new do |s|
  s.name              = "etcd-ruby"
  s.version           = "0.0.1"
  s.summary           = "API for the coreos/etcd daemon"
  s.description       = "API for the coreos/etcd daemon"
  s.authors           = ["Jacques Fuentes"]
  s.email             = ["jpfuentes2@gmail.com"]
  s.homepage          = "https://github.com/jpfuentes2/etcd-ruby"
  s.license           = "MIT"
  s.files             = Dir[
    "README*",
    "LICENSE",
    "lib/**/*.rb",
    "test/**/*.rb"
  ]

  s.add_dependency "json"
end
