# coding: utf-8
name "test5"
version "10.11.12"
maintainer "Noah Kantrowitz"
maintainer_email "noah@coderanger.net"
source_url "http://example.com/" if defined?(source_url)
license "Apache 2.0"
depends "test2", "~> 4.5.6"
gem "test6", "~> 13.14.15"
chef_version ">= 12.8.1" if defined?(chef_version)
