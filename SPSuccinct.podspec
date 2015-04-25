Pod::Spec.new do |s|
  s.name     = 'SPSuccinct'
  s.version  = '1.0.4'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Tools to write succinct Objective-C.'
  s.homepage = 'https://github.com/nevyn/SPSuccinct'
  s.author   = { 'Joachim Bengtsson' => 'joachimb@gmail.com' }

  s.source   = { :git => "https://github.com/nevyn/SPSuccinct.git", :tag => "1.0.4" }

  s.description = 'Object-based KVO tools, some functional programming tools, macros for "plain old data" literals, , and SPDepends.'

  s.source_files = [
    "SPSuccinct/SPDebugging.h",
    "SPSuccinct/SPDepends.h",
    "SPSuccinct/SPDepends.m",
    "SPSuccinct/SPFunctional.h",
    "SPSuccinct/SPFunctional.m",
    "SPSuccinct/SPKVONotificationCenter.h",
    "SPSuccinct/SPKVONotificationCenter.m",
    "SPSuccinct/SPLifetimeGlue.h",
    "SPSuccinct/SPLowVerbosity.h",
    "SPSuccinct/SPLowVerbosity.m",
    "SPSuccinct/SPSuccinct.h",
  ]
  s.requires_arc = true
  
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = [
      "SPSuccinct/SPLifetimeGlue.h",
      "SPSuccinct/SPLifetimeGlue.m",
      "SPSuccinct/SPDebugging.h",
      "SPSuccinct/SPDebugging.m",
    ]
  end
end
