Pod::Spec.new do |s|
  s.name         = "MaterialComponentsSnapshotTests"
  s.version      = "77.0.0"
  s.authors      = "The Material Components authors."
  s.summary      = "This spec is an aggregate of all the Material Components snapshot tests."
  s.homepage     = "https://github.com/material-components/material-components-ios"
  s.license      = 'Apache 2.0'
  s.source       = { :git => "https://github.com/material-components/material-components-ios.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.dependency 'MaterialComponents'
  s.dependency 'MaterialComponentsBeta'
  s.dependency 'iOSSnapshotTestCase/Core', '2.2.0'

  s.source_files = "components/private/Snapshot/src/*.{h,m,swift}"

  s.subspec "BottomAppBar" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}"
    end
  end

  s.subspec "BottomNavigation" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}"
    end
  end

  s.subspec "Buttons" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}"
    end
  end

  s.subspec "ButtonBar" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}"
    end
  end

  s.subspec "Cards" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}"
      snapshot_tests.resources = "components/#{component.base_name}/tests/snapshot/resources/*"
    end
  end

  s.subspec "Chips" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = [
        "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}",
        "components/#{component.base_name}/tests/snapshot/supplemental/*.{h,m,swift}"
      ]
      snapshot_tests.resources = "components/#{component.base_name}/tests/snapshot/resources/*"
    end
  end

  s.subspec "Dialogs" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = [
        "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}",
        "components/#{component.base_name}/tests/snapshot/supplemental/*.{h,m,swift}"
      ]
      snapshot_tests.resources = "components/#{component.base_name}/tests/snapshot/resources/*"
    end
  end

  s.subspec "Ripple" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = [
        "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}",
        "components/#{component.base_name}/tests/snapshot/supplemental/*.{h,m,swift}",
      ]
    end
  end

  s.subspec "Slider" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = [
        "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}",
        "components/#{component.base_name}/tests/snapshot/supplemental/*.{h,m,swift}",
      ]
    end
  end

  s.subspec "TextFields" do |component|
    component.ios.deployment_target = '8.0'
    component.test_spec 'SnapshotTests' do |snapshot_tests|
      snapshot_tests.requires_app_host = true
      snapshot_tests.source_files = [
        "components/#{component.base_name}/tests/snapshot/*.{h,m,swift}",
        "components/#{component.base_name}/tests/snapshot/supplemental/*.{h,m,swift}"
      ]
      snapshot_tests.resources = "components/#{component.base_name}/tests/snapshot/resources/*"
      snapshot_tests.dependency "MDFInternationalization"
    end
  end
end
