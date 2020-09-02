# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name         = 'ApplicasterIAP'
  s.version      = '0.1.1'
  s.summary      = 'In App Purchases framework'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/applicaster/applicaster-iap-framework'
  s.author       = { 'Roman Karpievich' => 'r.karpievich@applicaster.com' }
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.swift_version = '5.2'
  s.source       = { git: 'https://github.com/applicaster/applicaster-iap-framework', tag: s.version }
  s.source_files = '**/*.{swift}', 'ApplicasterIAP/**/*.{m}'
  s.requires_arc = true

  s.dependency 'React'
end
