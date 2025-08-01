require 'glimmer-dsl-libui'
require 'mini_magick'
require 'fileutils'
require 'shellwords'

include Glimmer

# Supported output formats for ImageMagick
FORMATS = %w[
  aai apng art arw avs bayer bpg bmp bmp2 bmp3 brf cals cin cip cmyk cmyka cr2 crw cube cur cut
  dcm dcr dcx dds dib djvu dmr dng dot dpx epdf epi eps eps2 eps3 epsf epsi ept exr farbfeld fax
  fits fl32 flif fpx ftxt gif gray graya group4 hdr heic hrz ico info isobrl isobrl6 jbig jng jp2
  jpt j2c j2k jpeg jxl jxr kernel mat miff mng mono mpc mpo mpr mrw msl mtv mvg nef orf ora otb p7
  palm pam pbm pcd pcds pcx pdb pfm pgm phm picon pict pix png png00 png24 png32 png48 png64 png8
  pnm ppm psb psd ptif pwp qoi rad raf raw rgb rgb565 rgba rgf rla rle sct sfw sf3 sgi sid
  sparse-color strimg sun svg tga tiff tim uhdr uil uyvy vicar viff wbmp wdp webp xbm xcf xpm xwd
  x3f ycbcra yuv
]
QUALITY = %w[100 90 80 70 60 50 40 30 20 10]
SIZE = %w[100% 90% 80% 75% 70% 60% 50% 25%]

window('Image Converter', 550, 550) {
  margined true

  vertical_box {
    padded true

    grid {
      padded true

      label('Input Image:') {
        left 0
        top 0
      }

      horizontal_box {
        left 1
        top 0
        xspan 3

        @input_path_entry = entry {
          stretchy true
          read_only true
        }

        button('Select Image') {
          stretchy false
          on_clicked {
            file = open_file
            if file
              @input_path_entry.text = file
              begin
                detected_format = MiniMagick::Image.open(file).type.downcase
                index = FORMATS.index(detected_format)
                if index
                  @format_combobox.selected = index
                else
                  msg_box_error('Warning', 'Unsupported input format. You can still choose output format.')
                end
              rescue => e
                msg_box_error('Error', "Failed to detect format: #{e.message}")
              end
            end
          }
        }
      }

      label('Output Folder:') {
        left 0
        top 1
      }

      horizontal_box {
        left 1
        top 1
        xspan 3

        @output_folder_entry = entry {
          stretchy true
          read_only true
        }

        button('Select Folder') {
          stretchy false
          on_clicked {
            folder = open_folder
            @output_folder_entry.text = folder if folder
          }
        }
      }

      horizontal_separator {
        left 0
        top 2
        xspan 3
        hexpand true
        vexpand false
      }

      label('Output Format:') {
        left 0
        top 3
        xspan 2
        halign :start
        valign :center
      }

      @format_combobox = combobox {
        left 1
        top 3
        xspan 1
        items FORMATS
        selected 0
      }

      label('Quality:') {
        left 0
        top 4
        xspan 2
        halign :start
        valign :top
      }

      @quality_combobox = combobox {
        left 1
        top 4
        xspan 2
        hexpand false
        items QUALITY
        selected QUALITY.index('100')
      }

      label('Size:') {
        left 0
        top 5
        xspan 2
        halign :start
        valign :bottom
      }

      @size_combobox = combobox {
        left 1
        top 5
        xspan 1
        hexpand true
        items SIZE
        selected SIZE.index('100%')
      }
    }

    horizontal_separator {
      stretchy false
    }

    button('Convert') {
      stretchy false
      on_clicked {
        input_path = @input_path_entry.text
        output_folder = @output_folder_entry.text
        target_format = FORMATS[@format_combobox.selected]
        quality_setting = QUALITY[@quality_combobox.selected].to_i
        size_setting = SIZE[@size_combobox.selected]

        if input_path.empty? || output_folder.empty? || target_format.nil?
          msg_box_error('Error', 'Please select an input image, output folder, and format.')
          next
        end

        begin
          image = MiniMagick::Image.open(input_path)
          base_filename = File.basename(input_path, File.extname(input_path))
          input_ext = image.type.downcase
          output_path = File.join(output_folder, "#{base_filename}.#{target_format}")

          if size_setting != '100%' && target_format != 'ico'
            image.resize size_setting
          end

          if %w[svg].include?(input_ext) && system('which rsvg-convert > /dev/null 2>&1')  # Fallback for SVG if librsvg available
            temp_png = File.join(Dir.tmpdir, "#{base_filename}_temp.png")
            resize_option = ""
            if size_setting != '100%'
              zoom_factor = size_setting.gsub('%', '').to_f / 100.0
              resize_option = "--zoom=#{zoom_factor}"
            end
            system("rsvg-convert #{Shellwords.escape(input_path)} -f png -o #{Shellwords.escape(temp_png)} #{resize_option}")
            raise "rsvg-convert failed" unless $?.success?
            image = MiniMagick::Image.open(temp_png)
            File.delete(temp_png)
          else
            image = MiniMagick::Image.open(input_path)
            if size_setting != '100%' && target_format != 'ico'
              image.resize size_setting
            end
          end

          image.quality(quality_setting.to_s)

          if target_format == 'ico' && (image.width > 256 || image.height > 256)
            image.resize '256x256>'
          end

          image.format(target_format)
          image.write(output_path)

          msg_box('Success', "Image converted and saved to:\n#{output_path}")
        rescue MiniMagick::Error => e
          msg_box_error('Conversion Error', "An error occurred: #{e.message}")
        rescue => e
          msg_box_error('Unexpected Error', "Something went wrong: #{e.message}")
        end
      }
    }
  }
}.show
