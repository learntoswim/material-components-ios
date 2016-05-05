# This file was automatically generated by running ./scripts/sync_icons.sh
# Do not modify directly.
def registerIcons(s)

  s.subspec "Icons" do |iss|
    iss.subspec "Base" do |ss|
      ss.public_header_files = "components/private/Icons/src/*.h"
      ss.source_files = "components/private/Icons/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/src/*"
    end

    iss.subspec "ic_arrow_back" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_arrow_back/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_arrow_back/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_arrow_back/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_arrow_back" => [
          "components/private/Icons/icons/ic_arrow_back/src/MaterialIcons_ic_arrow_back.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end

    iss.subspec "ic_check" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_check/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_check/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_check/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_check" => [
          "components/private/Icons/icons/ic_check/src/MaterialIcons_ic_check.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end

    iss.subspec "ic_check_circle" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_check_circle/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_check_circle/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_check_circle/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_check_circle" => [
          "components/private/Icons/icons/ic_check_circle/src/MaterialIcons_ic_check_circle.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end

    iss.subspec "ic_chevron_right" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_chevron_right/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_chevron_right/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_chevron_right/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_chevron_right" => [
          "components/private/Icons/icons/ic_chevron_right/src/MaterialIcons_ic_chevron_right.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end

    iss.subspec "ic_info" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_info/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_info/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_info/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_info" => [
          "components/private/Icons/icons/ic_info/src/MaterialIcons_ic_info.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end

    iss.subspec "ic_radio_button_unchecked" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_radio_button_unchecked/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_radio_button_unchecked/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_radio_button_unchecked/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_radio_button_unchecked" => [
          "components/private/Icons/icons/ic_radio_button_unchecked/src/MaterialIcons_ic_radio_button_unchecked.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end

    iss.subspec "ic_reorder" do |ss|
      ss.public_header_files = "components/private/Icons/icons/ic_reorder/src/*.h"
      ss.source_files = "components/private/Icons/icons/ic_reorder/src/*.{h,m}"
      ss.header_mappings_dir = "components/private/Icons/icons/ic_reorder/src/*"
      ss.resource_bundles = {
        "MaterialIcons_ic_reorder" => [
          "components/private/Icons/icons/ic_reorder/src/MaterialIcons_ic_reorder.bundle/*.png",
        ]
      }
      ss.dependency "#{Pathname.new(ss.name).dirname}/Base"
    end
  end
end
