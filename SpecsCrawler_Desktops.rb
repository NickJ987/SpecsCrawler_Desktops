require 'nokogiri'
require 'open-uri'
require 'csv'

class Specs
	attr_reader :store, :sku, :pn, :url

  def initialize(store, sku, pn, url)
		@store = store
		@sku = sku
		@pn = pn
		@url = url
	end

  def parser
    @parser ||= Nokogiri::HTML(open(url, 'User-Agent' => 'chrome'))
  end

  def display_size
    begin
      display_size_lookup
    rescue => e
      "-"
    else
      display_size_lookup
    end
  end

  def display_resolution
    begin
      display_resolution_lookup
    rescue => e
      "-"
    else
      display_resolution_lookup
    end
  end

   def touchscreen
    begin
      touchscreen_lookup
    rescue => e
      "-"
    else
      touchscreen_lookup
    end
  end

  def processor_brand
    begin
      processor_brand_lookup
    rescue => e
      "-"
    else
      processor_brand_lookup
    end
  end

   def processor_family
    begin
      processor_family_lookup
    rescue => e
      "-"
    else
      processor_family_lookup
    end
  end

   def processor_model
    begin
      processor_model_lookup
    rescue => e
      "-"
    else
      processor_model_lookup
    end
  end

   def processor_speed
    begin
      processor_speed_lookup
    rescue => e
      "-"
    else
      processor_speed_lookup
    end
  end

   def operating_system
    begin
      operating_system_lookup
    rescue => e
      "-"
    else
      operating_system_lookup
    end
  end

     def storage_capacity
    begin
      storage_capacity_lookup
    rescue => e
      "-"
    else
      storage_capacity_lookup
    end
  end

     def std_ram
    begin
      std_ram_lookup
    rescue => e
      "-"
    else
      std_ram_lookup
    end
  end


  private
  def display_size_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributediagonal_screen_sizekey')[0].text.match(/[\d.]+/)
    when 'pcconnection'
      parser.css('tr > th:contains("Display Size") + td')[0].text.match(/[\d.]+/)
    when 'staples.com'
      parser.css('tr > td:contains("Screen Size") + td')[0].text.match(/[\d.]+/)
    end
  end

  def display_resolution_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributescreen_resolutionkey')[0].text.strip.gsub(" ","")
    when 'pcconnection'
      parser.css('tr > th:contains("Internal Resolution") + td')[0].text.strip.gsub(" ","")
    when 'staples.com'
      parser.css('tr > td:contains("Screen Resolution") + td')[0].text.strip.gsub(" ","")
    end
  end

  def touchscreen_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributetouchscreenkey')[0].text.strip
    when 'pcconnection'
      if parser.css('tr > th:contains("Input Device Type") + td')[0].text.match(/touch-screen/i)
        parser.css('tr > th:contains("Input Device Type") + td')[0].text.match(/touch-screen/i)
      else
      	"N"
      end
    when 'staples.com'
      parser.css('tr > td:contains("Touch Screen Enabled") + td')[0].text.strip.gsub("Yes","Y")
    end
  end

  def processor_brand_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributeprocessor_brandkey')[0].text.strip
    when 'pcconnection'
      parser.css('tr > th:contains("Processor Manufacturer") + td')[0].text.strip
    when 'staples.com'
      parser.css('tr > td:contains("Processor Type") + td')[0].text.strip
    end
  end

  def processor_family_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributeprocessor_typekey')[0].text.strip
    when 'pcconnection'
      parser.css('tr > th:contains("Processor Type") + td')[0].text.strip
    when 'staples.com'
      parser.css('tr > td:contains("Processor Type") + td')[0].text.strip
    end
  end

  def processor_model_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributeprocessor_modelkey')[0].text.strip
    when 'pcconnection'
      parser.css('tr > th:contains("Processor Model Number") + td')[0].text.strip
    end
  end

  def processor_speed_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributeprocessor_speedkey')[0].text.match(/[\d.]+/)
    when 'pcconnection'
      parser.css('tr > th:contains("Processor Speed") + td')[0].text.match(/[\d.]+/)
    when 'staples.com'
      parser.css('tr > td:contains("Processor Speed (Ghz)") + td')[0].text.match(/[\d.]+/)
    end
  end

  def operating_system_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributeoperating_systemskey')[0].text.match(/[\d.]+/)
    when 'pcconnection'
      parser.css('tr > th:contains("OS Provided") + td')[0].text.strip
    when 'staples.com'
      parser.css('tr > td:contains("Windows OS Version") + td')[0].text.strip

    end
  end

  def storage_capacity_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributehard_drive_capacitykey')[0].text.strip
    when 'pcconnection'
      parser.css('tr > th:contains("Hard Drive Capacity") + td')[0].text.strip
    when 'staples.com'
      parser.css('tr > td:contains("Desktop Hard Drive Size (GB)") + td')[0].text.strip
    end
  end

  def std_ram_lookup
    case store.downcase
    when 'officedepot.com'
      parser.css('#attributestandard_memorykey')[0].text.match(/[\d.]+/)
    when 'pcconnection'
      parser.css('tr > th:contains("RAM (installed)") + td')[0].text.match(/[\d]+/)
    when 'staples.com'
      parser.css('tr > td:contains("RAM Capacity") + td')[0].text.match(/[\d]+/)
    end
  end
end


contents = CSV.open "specs_lookup-input.csv", headers: true, header_converters: :symbol
contents.each do |row|

  product = Specs.new(row[:store], row[:sku], row[:pn], row[:url])

  puts product.store, product.sku, product.pn, product.url, product.display_size, product.display_resolution, product.touchscreen, product.processor_brand, product.processor_family, product.processor_model, product.processor_speed, product.operating_system, product.storage_capacity, product.std_ram

  CSV.open("specs_lookup-output.csv", 'a+', headers: true, header_converters: :symbol) do |in_file|
    in_file << [product.store, product.sku, product.pn, product.url, product.display_size, product.display_resolution, product.touchscreen, product.processor_brand, product.processor_family, product.processor_model, product.processor_speed, product.operating_system, product.storage_capacity, product.std_ram]
  end
end